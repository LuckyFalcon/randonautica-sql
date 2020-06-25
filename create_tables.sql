DROP TABLE trip_report_hashtags
DROP TABLE hashtags
DROP TABLE trip_report_media
DROP TABLE trip_reports
DROP TABLE purchase_histories
DROP TABLE products
DROP TABLE achievement_histories
DROP TABLE achievements
DROP TABLE user_details
DROP TABLE users

CREATE TABLE users
(
    id UNIQUEIDENTIFIER DEFAULT NEWSEQUENTIALID() PRIMARY KEY,
    name NVARCHAR(100),
    created DATETIME2,
    updated DATETIME2
)
CREATE INDEX users_index ON users (id, name, created, updated)

CREATE TABLE user_details
(
    id UNIQUEIDENTIFIER DEFAULT NEWSEQUENTIALID() PRIMARY KEY,
    user_id UNIQUEIDENTIFIER FOREIGN KEY REFERENCES users(id),
    platform TINYINT, -- enum: 0 - iOS, 1 - Android, 3 - Amazon, 4 - Web ... TODO needed? How to handle users who have multiple devices
    last_signedin_datetime DATETIME2,
    points INT, -- balance of ingame currency (qpoints, qapples, whatever the naming ends up being)
    is_iap_skip_water_points TINYINT, -- enum: 0 - disabled, 1 enabled
    is_iap_extend_radius TINYINT, -- enum: 0 - disabled, 1 enabled
    is_iap_location_search TINYINT, -- enum: 0 - disabled, 1 enabled
    is_iap_inapp_google_preview TINYINT, -- enum: 0 - disabled, 1 enabled
    created DATETIME2,
    updated DATETIME2
)
CREATE INDEX user_details_index ON user_details (id, user_id, created, updated)

CREATE TABLE products
(
    id UNIQUEIDENTIFIER DEFAULT NEWSEQUENTIALID() PRIMARY KEY,
    product_id NVARCHAR(100),
    type tinyint, -- enum 0 - consumable, 1 - non-consumable, 3 - subscription
    created DATETIME2,
    updated DATETIME2
)
CREATE INDEX products_index ON products (id, product_id, created, updated)

CREATE TABLE purchase_histories
(
    id UNIQUEIDENTIFIER DEFAULT NEWSEQUENTIALID() PRIMARY KEY,
    product_id UNIQUEIDENTIFIER FOREIGN KEY REFERENCES users(id),
    user_id UNIQUEIDENTIFIER FOREIGN KEY REFERENCES products(id),
    purchase_id NVARCHAR(2000), -- == order_id // TODO: check this warning from idexing this column: Warning! The maximum key length for a nonclustered index is 1700 bytes. The index 'purchase_histories_index' has maximum length of 4233 bytes. For some combination of large values, the insert/update operation will fail.
    local_verification_data NVARCHAR(4000), -- TODO: confirm max length
    server_verification_data NVARCHAR(4000), -- TODO: confirm max length
    source TINYINT, -- enum: 0 - GooglePlay, 1 - AppStore
    transaction_date NVARCHAR(100),
    status TINYINT, -- enum: 0 - pending, 1 - purchased, 2 - error (cancelled)
    error_code NVARCHAR(2000), -- TODO: confirm max length
    error_message NVARCHAR(2000), -- TODO: confirm max length
    error_details NVARCHAR(4000), -- TODO: confirm max length
    created DATETIME2,
    updated DATETIME2
)
CREATE INDEX purchase_histories_index ON purchase_histories (id, status, purchase_id, transaction_date, created, updated)

CREATE TABLE achievements
(
    id UNIQUEIDENTIFIER DEFAULT NEWSEQUENTIALID() PRIMARY KEY,
    -- TODO: need an iname type field?
    name NVARCHAR(200),
    created DATETIME2,
    updated DATETIME2
)
CREATE INDEX achievements_index ON achievements (id, created, updated)

CREATE TABLE achievement_histories
(
    id UNIQUEIDENTIFIER DEFAULT NEWSEQUENTIALID() PRIMARY KEY,
    achievement_id UNIQUEIDENTIFIER FOREIGN KEY REFERENCES achievements(id),
    user_id UNIQUEIDENTIFIER FOREIGN KEY REFERENCES users(id),
    score INT, -- TODO: not sure if needed? achievements to be designed properly later
    is_achieved TINYINT, -- enum: 0 - no, 1 - yes
    date_achieved DATETIME2,
    created DATETIME2,
    updated DATETIME2
)
CREATE INDEX achievement_histories_index ON achievement_histories (id, created, updated)

CREATE TABLE trip_reports
(
    id UNIQUEIDENTIFIER DEFAULT NEWSEQUENTIALID() PRIMARY KEY,
    user_id UNIQUEIDENTIFIER FOREIGN KEY REFERENCES users(id),
    is_visited TINYINT, -- boolean 0 = not visited, 1 = visited
    is_logged TINYINT, -- boolean 0 = not logged, 1 = logged
    is_favorite TINYINT, -- boolean 0 = not favorite, 1 = is favorite

    -- TODO: add a column(s) for tracking posted logs to Twitter/Reddit etc?
    
    rng_type TINYINT, -- enum: TODO define more. For now : 0 - ANU, 1 - CameraRNG, 3 - ComScire (Mind Drive)
    point_type TINYINT, -- enum: 0 - Anomaly, 1 - Attractor, 3 - Void, 4 - single quantum point, 5 - single pseudo point... others like Mystery/Quantum Time etc?
    title NVARCHAR(200), -- give your trip a name
    report NVARCHAR(4000), -- tell your story (actual report text)
    
    what_3_words_address NVARCHAR(500),
    what_3_words_nearest_place NVARCHAR(500),
    what_3_words_country NVARCHAR(200),

    center geography,
    latitude FLOAT(53),
    longitude FLOAT(53),

    newtonlib_gid NVARCHAR(100),
    newtonlib_tid NVARCHAR(100),
    newtonlib_lid NVARCHAR(100),
    newtonlib_type TINYINT,
    newtonlib_x FLOAT(53),
    newtonlib_y FLOAT(53),
    newtonlib_distance FLOAT(53),
    newtonlib_initial_bearing FLOAT(53),
    newtonlib_final_bearing FLOAT(53),
    newtonlib_side INT,
    newtonlib_distance_err FLOAT(53),
    newtonlib_radiusM FLOAT(53),
    newtonlib_number_points INT,
    newtonlib_mean FLOAT(53),
    newtonlib_rarity INT,
    newtonlib_power_old FLOAT(53),
    newtonlib_power FLOAT(53),
    newtonlib_z_score FLOAT(53),
    newtonlib_probability_single FLOAT(53),
    newtonlib_integral_score FLOAT(53),
    newtonlib_significance FLOAT(53),
    newtonlib_probability FLOAT(53),

    created DATETIME2,
    updated DATETIME2
)
CREATE INDEX trip_reports_index ON trip_reports (id, is_visited, is_logged, rng_type, point_type, latitude, longitude, newtonlib_power, newtonlib_z_score, created, updated)

CREATE TABLE trip_report_media
(
    id UNIQUEIDENTIFIER DEFAULT NEWSEQUENTIALID() PRIMARY KEY,
    trip_report_id UNIQUEIDENTIFIER FOREIGN KEY REFERENCES trip_reports(id),
    type TINYINT, -- enum 0 == photo, 1 == video
    blob_id NVARCHAR(1000), -- TODO: figure out how Azure Blob Storage IDs work
    created DATETIME2,
    updated DATETIME2
)
CREATE INDEX trip_report_media_index ON trip_report_media (id, created, updated)

CREATE TABLE hashtags
(
    id UNIQUEIDENTIFIER DEFAULT NEWSEQUENTIALID() PRIMARY KEY,
    hashtag NVARCHAR(100),
    created DATETIME2,
    updated DATETIME2
)
CREATE INDEX hashtags_index ON hashtags (id, hashtag, created, updated)

CREATE TABLE trip_report_hashtags
(
    id UNIQUEIDENTIFIER DEFAULT NEWSEQUENTIALID() PRIMARY KEY,
    trip_report_id UNIQUEIDENTIFIER FOREIGN KEY REFERENCES trip_reports(id),
    hashtag_id UNIQUEIDENTIFIER FOREIGN KEY REFERENCES hashtags(id),
    created DATETIME2,
    updated DATETIME2,
)
CREATE INDEX trip_report_hashtags_index ON trip_report_hashtags (id, created, updated)