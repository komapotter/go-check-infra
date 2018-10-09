-- +goose Up
-- SQL in this section is executed when the migration is applied.

INSERT INTO `area` (`display_order`, `name`, `memo`, `deleted_at`) VALUES
('1', '北部', '北', NULL),
('2', '中部', '中', NULL),
('3', '南部', '南', NULL),
('4', '東部', '東', NULL),
('5', '離島', '離', NULL);

-- +goose Down
-- SQL in this section is executed when the migration is rolled back.
