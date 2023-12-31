DROP DATABASE IF EXISTS isuumo;
CREATE DATABASE isuumo;

DROP TABLE IF EXISTS isuumo.estate;
DROP TABLE IF EXISTS isuumo.chair;

CREATE TABLE isuumo.estate
(
    id          INTEGER             NOT NULL PRIMARY KEY,
    name        VARCHAR(64)         NOT NULL,
    description VARCHAR(4096)       NOT NULL,
    thumbnail   VARCHAR(128)        NOT NULL,
    address     VARCHAR(128)        NOT NULL,
    latitude    DOUBLE PRECISION    NOT NULL,
    longitude   DOUBLE PRECISION    NOT NULL,
    rent        INTEGER             NOT NULL,
    door_height INTEGER             NOT NULL,
    door_width  INTEGER             NOT NULL,
    features    VARCHAR(64)         NOT NULL,
    popularity  INTEGER             NOT NULL,
    popularity_desc INTEGER AS (-popularity) NOT NULL,
    point       POINT AS (POINT(latitude, longitude)) STORED NOT NULL
);

CREATE TABLE isuumo.chair
(
    id          INTEGER         NOT NULL PRIMARY KEY,
    name        VARCHAR(64)     NOT NULL,
    description VARCHAR(4096)   NOT NULL,
    thumbnail   VARCHAR(128)    NOT NULL,
    price       INTEGER         NOT NULL,
    height      INTEGER         NOT NULL,
    width       INTEGER         NOT NULL,
    depth       INTEGER         NOT NULL,
    color       VARCHAR(64)     NOT NULL,
    features    VARCHAR(64)     NOT NULL,
    kind        VARCHAR(64)     NOT NULL,
    popularity  INTEGER         NOT NULL,
    popularity_desc INTEGER AS (-popularity) NOT NULL,
    stock       INTEGER         NOT NULL
);

ALTER TABLE isuumo.estate ADD INDEX estate_rent_id_idx(rent, id);
ALTER TABLE isuumo.estate ADD INDEX estate_popularity_id_idx(popularity_desc, id);
ALTER TABLE isuumo.estate ADD SPATIAL INDEX estate_point_idx(point);
ALTER TABLE isuumo.estate ADD INDEX estate_rent_door_width_idx(rent, door_width);
ALTER TABLE isuumo.estate ADD INDEX estate_rent_door_height_idx(rent, door_height);

ALTER TABLE isuumo.chair ADD INDEX chair_price_id_idx(price, id);
ALTER TABLE isuumo.chair ADD INDEX chair_popularity_id_idx(popularity_desc, id);
ALTER TABLE isuumo.chair ADD INDEX chair_price_idx(price, stock);
ALTER TABLE isuumo.chair ADD INDEX chair_height_idx(height, stock);
ALTER TABLE isuumo.chair ADD INDEX chair_kind_idx(kind, stock);
