APP := go-check-infra

.PHONY: build
build:
	@go build -o bin/${APP}

.PHONY: clean
clean:
	@rm -fr bin/*

.PHONY: deps
deps:
	@dep ensure -v

.PHONY: docker-build
docker-build:
	@docker-compose build

.PHONY: docker-start
docker-start:
	@docker-compose up -d

.PHONY: docker-start-db
docker-start-db:
	@docker-compose up -d db

.PHONY: docker-stop
docker-stop:
	@docker-compose down
