-- +goose Up
-- SQL in this section is executed when the migration is applied.

CREATE TABLE area
(
	id bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'ID',
	display_order int unsigned DEFAULT 0 NOT NULL COMMENT '表示順',
	name varchar(30) NOT NULL COMMENT 'エリア名',
	memo varchar(30) NOT NULL COMMENT 'メモ',
	created_at datetime DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT '作成日',
	updated_at datetime DEFAULT CURRENT_TIMESTAMP NOT NULL COMMENT '更新日',
    deleted_at datetime COMMENT '削除日',
	PRIMARY KEY (id)
) COMMENT = 'エリア';

-- +goose Down
-- SQL in this section is executed when the migration is rolled back.

DROP TABLE IF EXISTS area;
