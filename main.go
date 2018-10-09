package main

import (
	"fmt"
	"log"
	"net/http"
	"os"

	_ "github.com/go-sql-driver/mysql"
	"github.com/gocraft/dbr"
	"github.com/kelseyhightower/envconfig"
	"github.com/labstack/echo"
	"github.com/labstack/echo/middleware"
)

// CustomContext -
type CustomContext struct {
	echo.Context
	DB *dbr.Session
	TB string
	FS string
}

// Config -
type Config struct {
	DbHost string `required:"true"`
	DbPort string `required:"true"`
	DbUser string `required:"true"`
	DbPass string `required:"true"`
	DbName string `required:"true"`
	Table  string `required:"true"`
	FsPath string `required:"true"`
}

// Table -
type Table struct {
	ID   int64
	Name string
}

func checkRDS(c echo.Context) error {
	cc := c.(*CustomContext)
	var table []Table
	_, err := cc.DB.Select("*").From(cc.TB).Load(&table)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, err.Error())
	}
	return c.JSON(http.StatusOK, table)
}

func checkEFS(c echo.Context) error {
	cc := c.(*CustomContext)
	h, _ := os.Hostname()
	path := fmt.Sprintf("%s/check-efs-%s.txt", cc.FS, h)
	file, err := os.Create(path)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, err.Error())
	}
	defer file.Close()
	data := []byte("Hello EFS")
	_, err = file.Write(data)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, err.Error())
	}
	return c.String(http.StatusOK, fmt.Sprintf("success to write: %s", path))
}

func myCustomMiddleware(dsn, table, path string) echo.MiddlewareFunc {
	return func(h echo.HandlerFunc) echo.HandlerFunc {
		return func(c echo.Context) error {
			conn, err := dbr.Open("mysql", dsn, nil)
			if err != nil {
				return echo.NewHTTPError(http.StatusInternalServerError, err.Error())
			}
			defer conn.Close()
			sess := conn.NewSession(nil)

			cc := &CustomContext{
				Context: c,
			}
			cc.DB = sess
			cc.TB = table
			cc.FS = path
			return h(cc)
		}
	}
}

func main() {
	var cf Config
	err := envconfig.Process("", &cf)
	if err != nil {
		log.Fatal(err.Error())
	}
	dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s", cf.DbUser, cf.DbPass, cf.DbHost, cf.DbPort, cf.DbName)
	path := cf.FsPath
	table := cf.Table

	e := echo.New()

	// Custom Middleware
	e.Use(myCustomMiddleware(dsn, table, path))

	e.Use(middleware.Logger())
	e.Use(middleware.Recover())

	e.GET("/", func(c echo.Context) error {
		return c.String(http.StatusOK, "Hello, World!")
	})
	e.GET("/check-rds", checkRDS)
	e.GET("/check-efs", checkEFS)

	e.Logger.Fatal(e.Start(":1323"))
}
