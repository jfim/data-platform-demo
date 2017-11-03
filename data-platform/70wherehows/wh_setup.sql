SHOW DATABASES;

CREATE DATABASE wherehows;

USE wherehows;

GRANT ALL PRIVILEGES ON wherehows.* To 'wherehows'@'%' IDENTIFIED BY 'wherehows';


CREATE TABLE `dataset_compliance` (
  `dataset_id`                INT(10) UNSIGNED NOT NULL,
  `dataset_urn`               VARCHAR(500)     NOT NULL,
  `compliance_purge_type`     VARCHAR(30)      DEFAULT NULL
  COMMENT 'AUTO_PURGE,CUSTOM_PURGE,LIMITED_RETENTION,PURGE_NOT_APPLICABLE,PURGE_EXEMPTED',
  `compliance_purge_note`     MEDIUMTEXT       DEFAULT NULL
  COMMENT 'The additional information about purging if the purge type is PURGE_EXEMPTED',
  `compliance_entities`       MEDIUMTEXT       DEFAULT NULL
  COMMENT 'JSON: compliance fields',
  `confidentiality`           VARCHAR(50)      DEFAULT NULL
  COMMENT 'dataset level confidential category: confidential, highly confidential, etc',
  `dataset_classification`    VARCHAR(1000)    DEFAULT NULL
  COMMENT 'JSON: dataset level confidential classification',
  `modified_by`               VARCHAR(50)      DEFAULT NULL
  COMMENT 'last modified by',
  `modified_time`             INT UNSIGNED DEFAULT NULL
  COMMENT 'the modified time in epoch',
  PRIMARY KEY (`dataset_id`),
  UNIQUE KEY `dataset_urn` (`dataset_urn`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = latin1;

CREATE TABLE `dict_dataset` (
  `id`                          INT(11) UNSIGNED NOT NULL                                                                   AUTO_INCREMENT,
  `name`                        VARCHAR(200)                                                                                NOT NULL,
  `schema`                      MEDIUMTEXT CHARACTER SET utf8,
  `schema_type`                 VARCHAR(50)                                                                                 DEFAULT 'JSON'
  COMMENT 'JSON, Hive, DDL, XML, CSV',
  `properties`                  TEXT CHARACTER SET utf8,
  `fields`                      MEDIUMTEXT CHARACTER SET utf8,
  `urn`                         VARCHAR(500)                                                                                NOT NULL,
  `source`                      VARCHAR(50)                                                                                 NULL
  COMMENT 'The original data source type (for dataset in data warehouse). Oracle, Kafka ...',
  `location_prefix`             VARCHAR(200)                                                                                NULL,
  `parent_name`                 VARCHAR(500)                                                                                NULL
  COMMENT 'Schema Name for RDBMS, Group Name for Jobs/Projects/Tracking Datasets on HDFS ',
  `storage_type`                ENUM('Table', 'View', 'Avro', 'ORC', 'RC', 'Sequence', 'Flat File', 'JSON', 'BINARY_JSON', 'XML', 'Thrift', 'Parquet', 'Protobuff') NULL,
  `ref_dataset_id`              INT(11) UNSIGNED                                                                            NULL
  COMMENT 'Refer to Master/Main dataset for Views/ExternalTables',
  `is_active`                   BOOLEAN NULL COMMENT 'is the dataset active / exist ?',
  `is_deprecated`               BOOLEAN NULL COMMENT 'is the dataset deprecated by user ?',
  `dataset_type`                VARCHAR(30)                                                                                 NULL
  COMMENT 'hdfs, hive, kafka, teradata, mysql, sqlserver, file, nfs, pinot, salesforce, oracle, db2, netezza, cassandra, hbase, qfs, zfs',
  `hive_serdes_class`           VARCHAR(300)                                                                                NULL,
  `is_partitioned`              CHAR(1)                                                                                     NULL,
  `partition_layout_pattern_id` SMALLINT(6)                                                                                 NULL,
  `sample_partition_full_path`  VARCHAR(256)
  COMMENT 'sample partition full path of the dataset',
  `source_created_time`         INT UNSIGNED                                                                                NULL
  COMMENT 'source created time of the flow',
  `source_modified_time`        INT UNSIGNED                                                                                NULL
  COMMENT 'latest source modified time of the flow',
  `created_time`                INT UNSIGNED COMMENT 'wherehows created time',
  `modified_time`               INT UNSIGNED COMMENT 'latest wherehows modified',
  `wh_etl_exec_id`              BIGINT COMMENT 'wherehows etl execution id that modified this record',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_dataset_urn` (`urn`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = latin1;

CREATE TABLE `dict_dataset_sample` (
  `id`         INT(11) NOT NULL AUTO_INCREMENT,
  `dataset_id` INT(11)          NULL,
  `urn`        VARCHAR(200)     NULL,
  `ref_id`     INT(11)          NULL
  COMMENT 'Reference dataset id of which dataset that we fetch sample from. e.g. for tables we do not have permission, fetch sample data from DWH_STG correspond tables',
  `data`       MEDIUMTEXT,
  `modified`   DATETIME         NULL,
  `created`    DATETIME         NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ak_dict_dataset_sample__datasetid` (`dataset_id`)
)
  ENGINE = InnoDB
  AUTO_INCREMENT = 0
  DEFAULT CHARSET = utf8;

CREATE TABLE `dict_field_detail` (
  `field_id`           INT(11) UNSIGNED     NOT NULL AUTO_INCREMENT,
  `dataset_id`         INT(11) UNSIGNED     NOT NULL,
  `fields_layout_id`   INT(11) UNSIGNED     NOT NULL,
  `sort_id`            SMALLINT(6) UNSIGNED NOT NULL,
  `parent_sort_id`     SMALLINT(5) UNSIGNED NOT NULL,
  `parent_path`        VARCHAR(200)                  NULL,
  `field_name`         VARCHAR(100)         NOT NULL,
  `field_label`        VARCHAR(100)                  NULL,
  `data_type`          VARCHAR(50)          NOT NULL,
  `data_size`          INT(10) UNSIGNED              NULL,
  `data_precision`     TINYINT(4)                    NULL
  COMMENT 'only in decimal type',
  `data_fraction`      TINYINT(4)                    NULL
  COMMENT 'only in decimal type',
  `default_comment_id` INT(11) UNSIGNED              NULL
  COMMENT 'a list of comment_id',
  `comment_ids`        VARCHAR(500)                  NULL,
  `is_nullable`        CHAR(1)                       NULL,
  `is_indexed`         CHAR(1)                       NULL
  COMMENT 'only in RDBMS',
  `is_partitioned`     CHAR(1)                       NULL
  COMMENT 'only in RDBMS',
  `is_distributed`     TINYINT(4)                    NULL
  COMMENT 'only in RDBMS',
  `is_recursive`       CHAR(1)                       NULL,
  `confidential_flags` VARCHAR(200)                  NULL,
  `default_value`      VARCHAR(200)                  NULL,
  `namespace`          VARCHAR(200)                  NULL,
  `java_data_type`     VARCHAR(50)                   NULL
  COMMENT 'correspond type in java',
  `jdbc_data_type`     VARCHAR(50)                   NULL
  COMMENT 'correspond type in jdbc',
  `pig_data_type`      VARCHAR(50)                   NULL
  COMMENT 'correspond type in pig',
  `hcatalog_data_type` VARCHAR(50)                   NULL
  COMMENT 'correspond type in hcatalog',
  `modified`           TIMESTAMP            NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`field_id`),
  UNIQUE KEY `uix_dict_field__datasetid_parentpath_fieldname` (`dataset_id`, `parent_path`, `field_name`) USING BTREE,
  UNIQUE KEY `uix_dict_field__datasetid_sortid` (`dataset_id`, `sort_id`) USING BTREE
)
  ENGINE = InnoDB
  AUTO_INCREMENT = 0
  DEFAULT CHARSET = latin1
  COMMENT = 'Flattened Fields/Columns';

CREATE TABLE `dict_dataset_schema_history` (
  `id`            INT(11) AUTO_INCREMENT NOT NULL,
  `dataset_id`    INT(11)                NULL,
  `urn`           VARCHAR(200)           NOT NULL,
  `modified_date` DATE                   NULL,
  `schema`        MEDIUMTEXT CHARACTER SET utf8 NULL,
  PRIMARY KEY (id),
  UNIQUE KEY `uk_dict_dataset_schema_history__urn_modified` (`urn`, `modified_date`)
)
  ENGINE = InnoDB
  AUTO_INCREMENT = 0;

CREATE TABLE `dict_dataset_field_comment` (
  `field_id`   INT(11) UNSIGNED NOT NULL,
  `comment_id` BIGINT(20) NOT NULL,
  `dataset_id` INT(11) UNSIGNED NOT NULL,
  `is_default` TINYINT(1) NULL DEFAULT '0',
  PRIMARY KEY (field_id, comment_id),
  KEY (comment_id)
)
  ENGINE = InnoDB;

-- dataset comments
CREATE TABLE comments (
  `id`           INT(11) AUTO_INCREMENT                                                                       NOT NULL,
  `text`         TEXT CHARACTER SET utf8                                                                      NOT NULL,
  `user_id`      INT(11)                                                                                      NOT NULL,
  `dataset_id`   INT(11)                                                                                      NOT NULL,
  `created`      DATETIME                                                                                     NULL,
  `modified`     DATETIME                                                                                     NULL,
  `comment_type` ENUM('Description', 'Grain', 'Partition', 'ETL Schedule', 'DQ Issue', 'Question', 'Comment') NULL,
  PRIMARY KEY (id),
  KEY `user_id` (`user_id`) USING BTREE,
  KEY `dataset_id` (`dataset_id`) USING BTREE,
  FULLTEXT KEY `fti_comment` (`text`)
)
  ENGINE = InnoDB
  CHARACTER SET latin1
  COLLATE latin1_swedish_ci
  AUTO_INCREMENT = 0;

-- field comments
CREATE TABLE `field_comments` (
  `id`                     INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`                INT(11)          NOT NULL DEFAULT '0',
  `comment`                VARCHAR(4000)    NOT NULL,
  `created`                TIMESTAMP        NOT NULL,
  `modified`               TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `comment_crc32_checksum` INT(11) UNSIGNED          NULL COMMENT '4-byte CRC32',
  PRIMARY KEY (`id`),
  KEY `comment_key` (`comment`(100)),
  FULLTEXT KEY `fti_comment` (`comment`)
)
  ENGINE = InnoDB
  AUTO_INCREMENT = 0
  DEFAULT CHARSET = utf8;

-- dict_dataset_instance
CREATE TABLE dict_dataset_instance  (
  dataset_id            int(11) UNSIGNED NOT NULL,
  db_id                 smallint(6) UNSIGNED COMMENT 'FK to cfg_database'  NOT NULL DEFAULT '0',
  deployment_tier       enum('local','grid','dev','int','ei','ei2','ei3','qa','stg','prod') NOT NULL DEFAULT 'dev',
  data_center           varchar(30) COMMENT 'data center code: lva1, ltx1, dc2, dc3...'  NULL DEFAULT '*',
  server_cluster        varchar(150) COMMENT 'sfo1-bigserver, jfk3-sqlserver03'  NULL DEFAULT '*',
  slice                 varchar(50) COMMENT 'virtual group/tenant id/instance tag'  NOT NULL DEFAULT '*',
  is_active             BOOLEAN NULL COMMENT 'is the dataset active / exist ?',
  is_deprecated         BOOLEAN NULL COMMENT 'is the dataset deprecated by user ?',
  native_name           varchar(250) NOT NULL,
  logical_name          varchar(250) NOT NULL,
  version               varchar(30) COMMENT '1.2.3 or 0.3.131'  NULL,
  version_sort_id       bigint(20) COMMENT '4-digit for each version number: 000100020003, 000000030131'  NOT NULL DEFAULT '0',
  schema_text           MEDIUMTEXT CHARACTER SET utf8 NULL,
  ddl_text              MEDIUMTEXT CHARACTER SET utf8 NULL,
  instance_created_time int(10) UNSIGNED COMMENT 'source instance created time'  NULL,
  created_time          int(10) UNSIGNED COMMENT 'wherehows created time'  NULL,
  modified_time         int(10) UNSIGNED COMMENT 'latest wherehows modified'  NULL,
  wh_etl_exec_id        bigint(20) COMMENT 'wherehows etl execution id that modified this record'  NULL,
  PRIMARY KEY(dataset_id,db_id,version_sort_id)
)
ENGINE = InnoDB
CHARACTER SET latin1;

CREATE TABLE `log_dataset_instance_load_status` (
  `dataset_id` int(11) NOT NULL DEFAULT '0',
  `db_id` smallint(6) NOT NULL DEFAULT '0',
  `dataset_type` varchar(30) NOT NULL COMMENT 'hive,teradata,oracle,hdfs...',
  `dataset_native_name` varchar(200) NOT NULL,
  `operation_type` varchar(50) DEFAULT NULL COMMENT 'load, merge, compact, update, delete',
  `partition_grain` varchar(30) NOT NULL DEFAULT '' COMMENT 'snapshot, delta, daily, daily, monthly...',
  `partition_expr` varchar(500) DEFAULT NULL COMMENT 'partition name or expression',
  `data_time_expr` varchar(20) NOT NULL COMMENT 'datetime literal of the data datetime',
  `data_time_epoch` int(11) NOT NULL COMMENT 'epoch second of the data datetime',
  `record_count` bigint(20) DEFAULT NULL,
  `size_in_byte` bigint(20) DEFAULT NULL,
  `log_time_epoch` int(11) NOT NULL COMMENT 'When data is loaded or published',
  `ref_dataset_type` varchar(30) DEFAULT NULL COMMENT 'Refer to the underlying dataset',
  `ref_db_id` int(11) DEFAULT NULL COMMENT 'Refer to db of the underlying dataset',
  `ref_uri` varchar(300) DEFAULT NULL COMMENT 'Table name or HDFS location',
  `last_modified` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`dataset_id`,`db_id`,`partition_grain`,`data_time_epoch`),
  KEY `dataset_native_name` (`dataset_native_name`,`partition_expr`),
  KEY `ref_uri` (`ref_uri`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `cfg_application` (
  `app_id`                  SMALLINT    UNSIGNED NOT NULL,
  `app_code`                VARCHAR(128)         NOT NULL,
  `description`             VARCHAR(512)         NOT NULL,
  `tech_matrix_id`          SMALLINT(5) UNSIGNED DEFAULT '0',
  `doc_url`                 VARCHAR(512)         DEFAULT NULL,
  `parent_app_id`           INT(11) UNSIGNED     NOT NULL,
  `app_status`              CHAR(1)              NOT NULL,
  `last_modified`           TIMESTAMP            NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_logical`              CHAR(1)                       DEFAULT NULL,
  `uri_type`                VARCHAR(25)                   DEFAULT NULL,
  `uri`                     VARCHAR(1000)                 DEFAULT NULL,
  `lifecycle_layer_id`      TINYINT(4) UNSIGNED           DEFAULT NULL,
  `short_connection_string` VARCHAR(50)                   DEFAULT NULL,
  PRIMARY KEY (`app_id`),
  UNIQUE KEY `idx_cfg_application__appcode` (`app_code`) USING HASH
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;

CREATE TABLE cfg_database  (
  db_id                   smallint(6) UNSIGNED NOT NULL,
  db_code                 varchar(30) COMMENT 'Unique string without space'  NOT NULL,
  primary_dataset_type    varchar(30) COMMENT 'What type of dataset this DB supports' NOT NULL DEFAULT '*',
  description             varchar(128) NOT NULL,
  is_logical              char(1) COMMENT 'Is a group, which contains multiple physical DB(s)'  NOT NULL DEFAULT 'N',
  deployment_tier         varchar(20) COMMENT 'Lifecycle/FabricGroup: local,dev,sit,ei,qa,canary,preprod,pr'  NULL DEFAULT 'prod',
  data_center             varchar(200) COMMENT 'Code name of its primary data center. Put * for all data cen'  NULL DEFAULT '*',
  associated_dc_num       tinyint(4) UNSIGNED COMMENT 'Number of associated data centers'  NOT NULL DEFAULT '1',
  cluster                 varchar(200) COMMENT 'Name of Fleet, Group of Servers or a Server'  NULL DEFAULT '*',
  cluster_size            smallint(6) COMMENT 'Num of servers in the cluster'  NOT NULL DEFAULT '1',
  extra_deployment_tag1   varchar(50) COMMENT 'Additional tag. Such as container_group:HIGH'  NULL,
  extra_deployment_tag2   varchar(50) COMMENT 'Additional tag. Such as slice:i0001'  NULL,
  extra_deployment_tag3   varchar(50) COMMENT 'Additional tag. Such as region:eu-west-1'  NULL,
  replication_role        varchar(10) COMMENT 'master or slave or broker'  NULL,
  jdbc_url                varchar(1000) NULL,
  uri                     varchar(1000) NULL,
  short_connection_string varchar(50) COMMENT 'Oracle TNS Name, ODBC DSN, TDPID...' NULL,
  last_modified           timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY(db_id),
  UNIQUE KEY `uix_cfg_database__dbcode` (db_code) USING HASH
)
ENGINE = InnoDB
DEFAULT CHARSET = utf8
COMMENT = 'Abstract different storage instances as databases' ;


CREATE TABLE cfg_object_name_map  (
  obj_name_map_id         int(11) AUTO_INCREMENT NOT NULL,
  object_type             varchar(100) NOT NULL,
  object_sub_type         varchar(100) NULL,
  object_name             varchar(350) NOT NULL COMMENT 'this is the derived/child object',
  map_phrase              varchar(100) NULL,
  object_dataset_id       int(11) UNSIGNED NULL COMMENT 'can be the abstract dataset id for versioned objects',
  is_identical_map        char(1) NOT NULL DEFAULT 'N' COMMENT 'Y/N',
  mapped_object_type      varchar(100) NOT NULL,
  mapped_object_sub_type  varchar(100) NULL,
  mapped_object_name      varchar(350) NOT NULL COMMENT 'this is the original/parent object',
  mapped_object_dataset_id  int(11) UNSIGNED NULL COMMENT 'can be the abstract dataset id for versioned objects',
  description             varchar(500) NULL,
  last_modified           timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY(obj_name_map_id),
  KEY idx_cfg_object_name_map__mappedobjectname (mapped_object_name) USING BTREE,
  CONSTRAINT uix_cfg_object_name_map__objectname_mappedobjectname UNIQUE (object_name, mapped_object_name)
)
ENGINE = InnoDB
CHARACTER SET latin1
AUTO_INCREMENT = 1
COMMENT = 'Map alias (when is_identical_map=Y) and view dependency. Always map from Derived/Child (object) back to its Original/Parent (mapped_object)' ;


CREATE TABLE cfg_deployment_tier  (
  tier_id       tinyint(4) NOT NULL,
  tier_code     varchar(25) COMMENT 'local,dev,test,qa,stg,prod' NOT NULL,
  tier_label    varchar(50) COMMENT 'display full name' NULL,
  sort_id       smallint(6) COMMENT '3-digit for group, 3-digit within group' NOT NULL,
  last_modified timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY(tier_id),
  UNIQUE KEY uix_cfg_deployment_tier__tiercode (tier_code)
)
ENGINE = InnoDB
AUTO_INCREMENT = 0
COMMENT = 'http://en.wikipedia.org/wiki/Deployment_environment';


CREATE TABLE cfg_data_center  (
  data_center_id      smallint(6) NOT NULL DEFAULT '0',
  data_center_code    varchar(30) NOT NULL,
  data_center_name    varchar(50) NOT NULL,
  time_zone           varchar(50) NOT NULL,
  city                varchar(50) NOT NULL,
  state               varchar(25) NULL,
  country             varchar(50) NOT NULL,
  longtitude          decimal(10,6) NULL,
  latitude            decimal(10,6) NULL,
  data_center_status  char(1) COMMENT 'A,D,U' NULL,
  last_modified       timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY(data_center_id),
  UNIQUE KEY uix_cfg_data_center__datacentercode (data_center_code)
)
ENGINE = InnoDB
AUTO_INCREMENT = 0
COMMENT = 'https://en.wikipedia.org/wiki/Data_center' ;


CREATE TABLE cfg_cluster  (
  cluster_id              smallint(6) NOT NULL DEFAULT '0',
  cluster_code            varchar(80) NOT NULL,
  cluster_short_name      varchar(50) NOT NULL,
  cluster_type        varchar(50) NOT NULL,
  deployment_tier_code    varchar(25) NOT NULL,
  data_center_code        varchar(30) NULL,
  description             varchar(200) NULL,
  last_modified       timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY(cluster_id),
  UNIQUE KEY uix_cfg_cluster__clustercode (cluster_code)
)
COMMENT = 'https://en.wikipedia.org/wiki/Computer_cluster' ;


CREATE TABLE flow (
  app_id               SMALLINT UNSIGNED NOT NULL
  COMMENT 'application id of the flow',
  flow_id              INT UNSIGNED      NOT NULL
  COMMENT 'flow id either inherit from source or generated',
  flow_name            VARCHAR(255) COMMENT 'name of the flow',
  flow_group           VARCHAR(255) COMMENT 'flow group or project name',
  flow_path            VARCHAR(1024) COMMENT 'flow path from top level',
  flow_level           SMALLINT COMMENT 'flow level, 0 for top level flow',
  source_created_time  INT UNSIGNED COMMENT 'source created time of the flow',
  source_modified_time INT UNSIGNED COMMENT 'latest source modified time of the flow',
  source_version       VARCHAR(255) COMMENT 'latest source version of the flow',
  is_active            CHAR(1) COMMENT 'determine if it is an active flow',
  is_scheduled         CHAR(1) COMMENT 'determine if it is a scheduled flow',
  pre_flows            VARCHAR(2048) COMMENT 'comma separated flow ids that run before this flow',
  main_tag_id          INT COMMENT 'main tag id',
  created_time         INT UNSIGNED COMMENT 'wherehows created time of the flow',
  modified_time        INT UNSIGNED COMMENT 'latest wherehows modified time of the flow',
  wh_etl_exec_id       BIGINT COMMENT 'wherehows etl execution id that modified this record',
  PRIMARY KEY (app_id, flow_id),
  INDEX flow_path_idx (app_id, flow_path(255)),
  INDEX flow_name_idx (app_id, flow_group(127), flow_name(127))
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8
  COMMENT = 'Scheduler flow table' PARTITION BY HASH (app_id) PARTITIONS 8;

CREATE TABLE flow_job (
  app_id               SMALLINT UNSIGNED NOT NULL
  COMMENT 'application id of the flow',
  flow_id              INT UNSIGNED      NOT NULL
  COMMENT 'flow id',
  first_source_version VARCHAR(255) COMMENT 'first source version of the flow under this dag version',
  last_source_version  VARCHAR(255) COMMENT 'last source version of the flow under this dag version',
  dag_version          INT               NOT NULL
  COMMENT 'derived dag version of the flow',
  job_id               INT UNSIGNED      NOT NULL
  COMMENT 'job id either inherit from source or generated',
  job_name             VARCHAR(255) COMMENT 'job name',
  job_path             VARCHAR(1024) COMMENT 'job path from top level',
  job_type_id          SMALLINT COMMENT 'type id of the job',
  job_type             VARCHAR(63) COMMENT 'type of the job',
  ref_flow_id          INT UNSIGNED NULL COMMENT 'the reference flow id of the job if the job is a subflow',
  pre_jobs             VARCHAR(20000) CHAR SET latin1 COMMENT 'comma separated job ids that run before this job',
  post_jobs            VARCHAR(20000) CHAR SET latin1 COMMENT 'comma separated job ids that run after this job',
  is_current           CHAR(1) COMMENT 'determine if it is a current job',
  is_first             CHAR(1) COMMENT 'determine if it is the first job',
  is_last              CHAR(1) COMMENT 'determine if it is the last job',
  created_time         INT UNSIGNED COMMENT 'wherehows created time of the flow',
  modified_time        INT UNSIGNED COMMENT 'latest wherehows modified time of the flow',
  wh_etl_exec_id       BIGINT COMMENT 'wherehows etl execution id that create this record',
  PRIMARY KEY (app_id, job_id, dag_version),
  INDEX flow_id_idx (app_id, flow_id),
  INDEX ref_flow_id_idx (app_id, ref_flow_id),
  INDEX job_path_idx (app_id, job_path(255))
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8
  COMMENT = 'Scheduler job table' PARTITION BY HASH (app_id) PARTITIONS 8;

CREATE TABLE flow_dag (
  app_id         SMALLINT UNSIGNED NOT NULL
  COMMENT 'application id of the flow',
  flow_id        INT UNSIGNED NOT NULL
  COMMENT 'flow id',
  source_version VARCHAR(255) COMMENT 'last source version of the flow under this dag version',
  dag_version    INT COMMENT 'derived dag version of the flow',
  dag_md5        VARCHAR(255) COMMENT 'md5 checksum for this dag version',
  is_current     CHAR(1) COMMENT 'if this source version of the flow is current',
  wh_etl_exec_id BIGINT COMMENT 'wherehows etl execution id that create this record',
  PRIMARY KEY (app_id, flow_id, source_version),
  INDEX flow_dag_md5_idx (app_id, flow_id, dag_md5),
  INDEX flow_id_idx (app_id, flow_id)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8
  COMMENT = 'Flow dag reference table' PARTITION BY HASH (app_id) PARTITIONS 8;

CREATE TABLE flow_execution (
  app_id           SMALLINT UNSIGNED NOT NULL
  COMMENT 'application id of the flow',
  flow_exec_id     BIGINT UNSIGNED   NOT NULL
  COMMENT 'flow execution id either from the source or generated',
  flow_exec_uuid   VARCHAR(255) COMMENT 'source flow execution uuid',
  flow_id          INT UNSIGNED      NOT NULL
  COMMENT 'flow id',
  flow_name        VARCHAR(255) COMMENT 'name of the flow',
  source_version   VARCHAR(255) COMMENT 'source version of the flow',
  flow_exec_status VARCHAR(31) COMMENT 'status of flow execution',
  attempt_id       SMALLINT COMMENT 'attempt id',
  executed_by      VARCHAR(127) COMMENT 'people who executed the flow',
  start_time       INT UNSIGNED COMMENT 'start time of the flow execution',
  end_time         INT UNSIGNED COMMENT 'end time of the flow execution',
  is_adhoc         CHAR(1) COMMENT 'determine if it is a ad-hoc execution',
  is_backfill      CHAR(1) COMMENT 'determine if it is a back-fill execution',
  created_time     INT UNSIGNED COMMENT 'etl create time',
  modified_time    INT UNSIGNED COMMENT 'etl modified time',
  wh_etl_exec_id   BIGINT COMMENT 'wherehows etl execution id that create this record',
  PRIMARY KEY (app_id, flow_exec_id),
  INDEX flow_id_idx (app_id, flow_id),
  INDEX flow_name_idx (app_id, flow_name)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8
  COMMENT = 'Scheduler flow execution table' PARTITION BY HASH (app_id) PARTITIONS 8;

CREATE TABLE job_execution (
  app_id          SMALLINT UNSIGNED NOT NULL
  COMMENT 'application id of the flow',
  flow_exec_id    BIGINT UNSIGNED COMMENT 'flow execution id',
  job_exec_id     BIGINT UNSIGNED   NOT NULL
  COMMENT 'job execution id either inherit or generated',
  job_exec_uuid   VARCHAR(255) COMMENT 'job execution uuid',
  flow_id         INT UNSIGNED      NOT NULL
  COMMENT 'flow id',
  source_version  VARCHAR(255) COMMENT 'source version of the flow',
  job_id          INT UNSIGNED      NOT NULL
  COMMENT 'job id',
  job_name        VARCHAR(255) COMMENT 'job name',
  job_exec_status VARCHAR(31) COMMENT 'status of flow execution',
  attempt_id      SMALLINT COMMENT 'attempt id',
  start_time      INT UNSIGNED COMMENT 'start time of the execution',
  end_time        INT UNSIGNED COMMENT 'end time of the execution',
  is_adhoc        CHAR(1) COMMENT 'determine if it is a ad-hoc execution',
  is_backfill     CHAR(1) COMMENT 'determine if it is a back-fill execution',
  created_time    INT UNSIGNED COMMENT 'etl create time',
  modified_time   INT UNSIGNED COMMENT 'etl modified time',
  wh_etl_exec_id  BIGINT COMMENT 'wherehows etl execution id that create this record',
  PRIMARY KEY (app_id, job_exec_id),
  INDEX flow_exec_id_idx (app_id, flow_exec_id),
  INDEX job_id_idx (app_id, job_id),
  INDEX flow_id_idx (app_id, flow_id),
  INDEX job_name_idx (app_id, flow_id, job_name)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8
  COMMENT = 'Scheduler job execution table' PARTITION BY HASH (app_id) PARTITIONS 8;

CREATE TABLE flow_schedule (
  app_id               SMALLINT UNSIGNED NOT NULL
  COMMENT 'application id of the flow',
  flow_id              INT UNSIGNED      NOT NULL
  COMMENT 'flow id',
  unit                 VARCHAR(31) COMMENT 'unit of time',
  frequency            INT COMMENT 'frequency of the unit',
  cron_expression      VARCHAR(127) COMMENT 'cron expression',
  is_active            CHAR(1) COMMENT 'determine if it is an active schedule',
  included_instances   VARCHAR(127) COMMENT 'included instance',
  excluded_instances   VARCHAR(127) COMMENT 'excluded instance',
  effective_start_time INT UNSIGNED COMMENT 'effective start time of the flow execution',
  effective_end_time   INT UNSIGNED COMMENT 'effective end time of the flow execution',
  created_time         INT UNSIGNED COMMENT 'etl create time',
  modified_time        INT UNSIGNED COMMENT 'etl modified time',
  ref_id               VARCHAR(255) COMMENT 'reference id of this schedule',
  wh_etl_exec_id       BIGINT COMMENT 'wherehows etl execution id that create this record',
  PRIMARY KEY (app_id, flow_id, ref_id),
  INDEX (app_id, flow_id)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8
  COMMENT = 'Scheduler flow schedule table' PARTITION BY HASH (app_id) PARTITIONS 8;

CREATE TABLE flow_owner_permission (
  app_id         SMALLINT UNSIGNED NOT NULL
  COMMENT 'application id of the flow',
  flow_id        INT UNSIGNED      NOT NULL
  COMMENT 'flow id',
  owner_id       VARCHAR(63) COMMENT 'identifier of the owner',
  permissions    VARCHAR(255) COMMENT 'permissions of the owner',
  owner_type     VARCHAR(31) COMMENT 'whether is a group owner or not',
  created_time   INT UNSIGNED COMMENT 'etl create time',
  modified_time  INT UNSIGNED COMMENT 'etl modified time',
  wh_etl_exec_id BIGINT COMMENT 'wherehows etl execution id that create this record',
  PRIMARY KEY (app_id, flow_id, owner_id),
  INDEX flow_index (app_id, flow_id),
  INDEX owner_index (app_id, owner_id)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8
  COMMENT = 'Scheduler owner table' PARTITION BY HASH (app_id) PARTITIONS 8;

CREATE TABLE `cfg_job_type` (
  `job_type_id` SMALLINT(6) UNSIGNED NOT NULL AUTO_INCREMENT,
  `job_type`    VARCHAR(50)          NOT NULL,
  `description` VARCHAR(200)         NULL,
  PRIMARY KEY (`job_type_id`),
  UNIQUE KEY `ak_cfg_job_type__job_type` (`job_type`)
)
  ENGINE = InnoDB
  AUTO_INCREMENT = 55
  DEFAULT CHARSET = utf8
  COMMENT = 'job types used in mutliple schedulers';

CREATE TABLE `cfg_job_type_reverse_map` (
  `job_type_actual`   VARCHAR(50)
                      CHARACTER SET ascii NOT NULL,
  `job_type_id`       SMALLINT(6) UNSIGNED NOT NULL,
  `description`       VARCHAR(200)         NULL,
  `job_type_standard` VARCHAR(50)          NOT NULL,
  PRIMARY KEY (`job_type_actual`),
  UNIQUE KEY `cfg_job_type_reverse_map_uk` (`job_type_actual`),
  KEY `cfg_job_type_reverse_map_job_type_id_fk` (`job_type_id`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8
  COMMENT = 'The reverse map of the actual job type to standard job type';

CREATE TABLE `job_execution_data_lineage` (
  `app_id` smallint(5) unsigned NOT NULL COMMENT 'FK: cfg_application',
  `flow_exec_id` bigint(20) unsigned DEFAULT NULL,
  `job_exec_id` bigint(20) unsigned NOT NULL DEFAULT '0' COMMENT 'FK: job_execution. In Azkaban this is a smart key combined e',
  `job_exec_uuid` varchar(100) DEFAULT NULL COMMENT 'Oozie has this value; yet some scheduler do not have this value, e.g. Azkaban',
  `flow_path` varchar(1024) DEFAULT NULL,
  `job_name` varchar(255) DEFAULT NULL,
  `canonical_job_type` varchar(50) DEFAULT NULL COMMENT 'FK: cfg_job_type',
  `job_start_unixtime` bigint(20) DEFAULT NULL,
  `job_finished_unixtime` bigint(20) DEFAULT NULL,
  `db_id` smallint(5) unsigned DEFAULT NULL COMMENT 'FK: cfg_database',
  `abstracted_object_name` varchar(255) DEFAULT NULL,
  `full_object_name` varchar(1000) DEFAULT NULL COMMENT 'original_object_name',
  `partition_start` varchar(50) DEFAULT NULL,
  `partition_end` varchar(50) DEFAULT NULL,
  `partition_type` varchar(20) DEFAULT NULL,
  `layout_id` smallint(5) unsigned DEFAULT NULL COMMENT 'path/location regexp/glob pattern of the dataset',
  `storage_type` varchar(16) DEFAULT NULL,
  `source_target_type` enum('source','target','lookup','temp') NOT NULL,
  `srl_no` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'the sorted number of this record in all records of this job',
  `source_srl_no` smallint(5) unsigned DEFAULT NULL COMMENT 'the most related source object for this target',
  `operation` varchar(64) DEFAULT NULL COMMENT 'INSERT,UPDATE,MERGE,DELETE,CREATE,REPLICATE,...',
  `target_filter_type` varchar(50) DEFAULT NULL COMMENT 'SUB_PARTITION,DWH_METRIC,SLIDE_WINDOW,...',
  `target_filter_detail` varchar(100) DEFAULT NULL COMMENT 'Sub Partition Name, List of METRIC_SK, Slide Window Offset...',
  `record_count` bigint(20) unsigned DEFAULT NULL,
  `insert_count` bigint(20) unsigned DEFAULT NULL,
  `delete_count` bigint(20) unsigned DEFAULT NULL,
  `update_count` bigint(20) unsigned DEFAULT NULL,
  `created_date` int(10) unsigned DEFAULT NULL,
  `wh_etl_exec_id` bigint(20) DEFAULT NULL COMMENT 'WhereHows ETL execution id that modified this record',
  `dataset_version` varchar(20) DEFAULT NULL COMMENT 'e.g. 1_0_23, applicable to DALI',
  PRIMARY KEY (`app_id`,`job_exec_id`,`srl_no`),
  KEY `idx_job_attempt_data_lineage__object_name` (`abstracted_object_name`,`source_target_type`) USING BTREE,
  KEY `idx_flow_path` (`app_id`,`flow_path`(300)) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Data Lineage Based On Job Execution. Only Successful Attempt';

CREATE TABLE job_attempt_source_code  (
  application_id  int(11) NOT NULL,
  job_id          int(11) NOT NULL,
  attempt_number  tinyint(4) NOT NULL,
  script_name     varchar(256) NULL,
  script_path     varchar(128) NOT NULL,
  script_type     varchar(16) NOT NULL,
  script_md5_sum  binary(16) NULL,
  created_date    datetime NOT NULL,
  PRIMARY KEY(application_id,job_id,attempt_number)
)
ENGINE = InnoDB
DEFAULT CHARSET = utf8;

CREATE TABLE `job_execution_script` (
  `app_id` int(11) NOT NULL,
  `job_id` int(11) NOT NULL,
  `script_name` varchar(512) NOT NULL DEFAULT '',
  `script_path` varchar(128) DEFAULT NULL,
  `script_type` varchar(16) NOT NULL,
  `chain_name` varchar(30) DEFAULT NULL,
  `job_name` varchar(30) DEFAULT NULL,
  `committer_name` varchar(128) NOT NULL DEFAULT '',
  `committer_email` varchar(128) DEFAULT NULL,
  `committer_ldap` varchar(30) DEFAULT NULL,
  `commit_time` datetime DEFAULT NULL,
  `script_url` varchar(512) DEFAULT NULL,
  PRIMARY KEY (`app_id`,`job_id`,`script_name`(100),`committer_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE dict_business_metric  (
  `metric_id`                 SMALLINT(6) UNSIGNED AUTO_INCREMENT NOT NULL,
  `metric_name`               VARCHAR(200) NOT NULL,
  `metric_description`        VARCHAR(500) NULL,
  `dashboard_name`            VARCHAR(100) COMMENT 'Hierarchy Level 1'  NULL,
  `metric_group`              VARCHAR(100) COMMENT 'Hierarchy Level 2'  NULL,
  `metric_category`           VARCHAR(100) COMMENT 'Hierarchy Level 3'  NULL,
  `metric_sub_category`         VARCHAR(100) COMMENT 'Additional Classification, such as Product, Line of Business' NULL,
  `metric_level`    VARCHAR(50) COMMENT 'CORE, DEPARTMENT, TEAM, OPERATION, STRATEGIC, TIER1, TIER2' NULL,
  `metric_source_type`        VARCHAR(50) COMMENT 'Table, Cube, File, Web Service'  NULL,
  `metric_source`             VARCHAR(300) CHAR SET latin1 COMMENT 'Table Name, Cube Name, URL'  NULL,
  `metric_source_dataset_id`  INT(11) COMMENT 'If metric_source can be matched in dict_dataset' NULL,
  `metric_ref_id_type`        VARCHAR(50) CHAR SET latin1 COMMENT 'DWH, ABTEST, FINANCE, SEGMENT, SALESAPP' NULL,
  `metric_ref_id`             VARCHAR(100) CHAR SET latin1 COMMENT 'ID in the reference system' NULL,
  `metric_type`     VARCHAR(100) COMMENT 'NUMBER, BOOLEAN, LIST' NULL,
  `metric_additive_type`      VARCHAR(100) COMMENT 'FULL, SEMI, NONE' NULL,
  `metric_grain`              VARCHAR(100) COMMENT 'DAILY, WEEKLY, UNIQUE, ROLLING 7D, ROLLING 30D' NULL,
  `metric_display_factor`     DECIMAL(10,4) COMMENT '0.01, 1000, 1000000, 1000000000' NULL,
  `metric_display_factor_sym` VARCHAR(20) COMMENT '%, (K), (M), (B), (GB), (TB), (PB)' NULL,
  `metric_good_direction` VARCHAR(20) COMMENT 'UP, DOWN, ZERO, FLAT' NULL,
  `metric_formula`            TEXT COMMENT 'Expression, Code Snippet or Calculation Logic' NULL,
  `dimensions`      VARCHAR(800) CHAR SET latin1 NULL,
  `owners`                  VARCHAR(300) NULL,
  `tags`      VARCHAR(300) NULL,
  `urn`                         VARCHAR(300) CHAR SET latin1 NOT NULL,
  `metric_url`      VARCHAR(300) CHAR SET latin1 NULL,
  `wiki_url`                VARCHAR(300) CHAR SET latin1 NULL,
  `scm_url`                 VARCHAR(300) CHAR SET latin1 NULL,
  `wh_etl_exec_id`              BIGINT COMMENT 'wherehows etl execution id that modified this record',
  PRIMARY KEY(metric_id),
  UNIQUE KEY `uq_dataset_urn` (`urn`),
  KEY `idx_dict_business_metric__ref_id` (`metric_ref_id`) USING BTREE,
  FULLTEXT KEY `fti_dict_business_metric_all` (`metric_name`, `metric_description`, `metric_category`, `metric_group`, `dashboard_name`)
)
  ENGINE = InnoDB;

CREATE TABLE dataset_owner (
  `dataset_id`    INT UNSIGNED NOT NULL,
  `dataset_urn`   VARCHAR(500) NOT NULL,
  `owner_id`      VARCHAR(127) NOT NULL,
  `app_id`        SMALLINT NOT NULL COMMENT 'application id of the namespace',
  `namespace`     VARCHAR(127) COMMENT 'the namespace of the user',
  `owner_type`    VARCHAR(127) COMMENT 'Producer, Consumer, Stakeholder',
  `owner_sub_type`  VARCHAR(127) COMMENT 'DWH, UMP, BA, etc',
  `owner_id_type` VARCHAR(127) COMMENT 'user, group, service, or urn',
  `owner_source`  VARCHAR(30) NOT NULL COMMENT 'where the owner info is extracted: JIRA,RB,DB,FS,AUDIT',
  `db_ids`        VARCHAR(127) COMMENT 'comma separated database ids',
  `is_group`      CHAR(1) COMMENT 'if owner is a group',
  `is_active`     CHAR(1) COMMENT 'if owner is active',
  `is_deleted`    CHAR(1) COMMENT 'if owner has been removed from the dataset',
  `sort_id`       SMALLINT COMMENT '0 = primary owner, order by priority/importance',
  `source_time`   INT UNSIGNED COMMENT 'the source time in epoch',
  `created_time`  INT UNSIGNED COMMENT 'the create time in epoch',
  `modified_time` INT UNSIGNED COMMENT 'the modified time in epoch',
  `confirmed_by`  VARCHAR(127) NULL,
  `confirmed_on`  INT UNSIGNED,
  wh_etl_exec_id  BIGINT COMMENT 'wherehows etl execution id that modified this record',
  PRIMARY KEY (`dataset_id`, `owner_id`, `app_id`, `owner_source`),
  UNIQUE KEY `with_urn` (`dataset_urn`, `owner_id`, `app_id`, `owner_source`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = latin1;

CREATE TABLE `dir_external_user_info` (
  `app_id` smallint(5) unsigned NOT NULL,
  `user_id` varchar(50) NOT NULL,
  `urn` varchar(200) DEFAULT NULL,
  `full_name` varchar(200) DEFAULT NULL,
  `display_name` varchar(200) DEFAULT NULL,
  `title` varchar(200) DEFAULT NULL,
  `employee_number` int(10) unsigned DEFAULT NULL,
  `manager_urn` varchar(200) DEFAULT NULL,
  `manager_user_id` varchar(50) DEFAULT NULL,
  `manager_employee_number` int(10) unsigned DEFAULT NULL,
  `default_group_name` varchar(100) DEFAULT NULL,
  `email` varchar(200) DEFAULT NULL,
  `department_id` int(10) unsigned DEFAULT '0',
  `department_name` varchar(200) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `mobile_phone` varchar(50) DEFAULT NULL,
  `is_active` char(1) DEFAULT 'Y',
  `org_hierarchy` varchar(500) DEFAULT NULL,
  `org_hierarchy_depth` tinyint(3) unsigned DEFAULT NULL,
  `created_time` int(10) unsigned DEFAULT NULL COMMENT 'the create time in epoch',
  `modified_time` int(10) unsigned DEFAULT NULL COMMENT 'the modified time in epoch',
  `wh_etl_exec_id` bigint(20) DEFAULT NULL COMMENT 'wherehows etl execution id that modified this record',
  PRIMARY KEY (`user_id`,`app_id`),
  KEY `email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `dir_external_group_user_map` (
  `app_id` smallint(5) unsigned NOT NULL,
  `group_id` varchar(50) NOT NULL,
  `sort_id` smallint(6) NOT NULL,
  `user_app_id` smallint(5) unsigned NOT NULL,
  `user_id` varchar(50) NOT NULL,
  `created_time` int(10) unsigned DEFAULT NULL COMMENT 'the create time in epoch',
  `modified_time` int(10) unsigned DEFAULT NULL COMMENT 'the modified time in epoch',
  `wh_etl_exec_id` bigint(20) DEFAULT NULL COMMENT 'wherehows etl execution id that modified this record',
  PRIMARY KEY (`app_id`,`group_id`,`user_app_id`,`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `dir_external_group_user_map_flatten` (
  `app_id` smallint(5) unsigned NOT NULL,
  `group_id` varchar(50) NOT NULL,
  `sort_id` smallint(6) NOT NULL,
  `user_id` varchar(50) NOT NULL,
  `user_app_id` smallint(5) unsigned NOT NULL,
  `created_time` int(10) unsigned DEFAULT NULL COMMENT 'the create time in epoch',
  `modified_time` int(10) unsigned DEFAULT NULL COMMENT 'the modified time in epoch',
  `wh_etl_exec_id` bigint(20) DEFAULT NULL COMMENT 'wherehows etl execution id that modified this record',
  PRIMARY KEY (`app_id`,`group_id`,`user_app_id`,`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE filename_pattern
(
  filename_pattern_id INT(11) NOT NULL AUTO_INCREMENT,
  regex               VARCHAR(100),
  PRIMARY KEY (filename_pattern_id)
);

-- partitions pattern to abstract from partition level to dataset level
CREATE TABLE `dataset_partition_layout_pattern` (
  `layout_id`               INT(11) NOT NULL AUTO_INCREMENT,
  `regex`                   VARCHAR(50)      DEFAULT NULL,
  `mask`                    VARCHAR(50)      DEFAULT NULL,
  `leading_path_index`      SMALLINT(6)      DEFAULT NULL,
  `partition_index`         SMALLINT(6)      DEFAULT NULL,
  `second_partition_index`  SMALLINT(6)      DEFAULT NULL,
  `sort_id`                 INT(11)          DEFAULT NULL,
  `comments`                VARCHAR(200)     DEFAULT NULL,
  `partition_pattern_group` VARCHAR(50)      DEFAULT NULL,
  PRIMARY KEY (`layout_id`)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;

CREATE TABLE users (
  id                       INT(11) AUTO_INCREMENT      NOT NULL,
  name                     VARCHAR(100)                NOT NULL,
  email                    VARCHAR(200)                NOT NULL,
  username                 VARCHAR(20)                 NOT NULL,
  department_number        INT(11)                     NULL,
  password_digest          VARCHAR(256)                NULL,
  password_digest_type     ENUM('SHA1', 'SHA2', 'MD5') NULL DEFAULT 'SHA1',
  ext_directory_ref_app_id SMALLINT UNSIGNED,
  authentication_type      VARCHAR(20),
  PRIMARY KEY (id)
)
  ENGINE = InnoDB
  AUTO_INCREMENT = 0
  DEFAULT CHARSET = utf8;

CREATE TABLE user_settings (
  user_id             INT(11)                           NOT NULL,
  detail_default_view VARCHAR(20)                       NULL,
  default_watch       ENUM('monthly', 'weekly', 'daily', 'hourly') NULL DEFAULT 'weekly',
  PRIMARY KEY (user_id)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;

CREATE TABLE watch (
  id                BIGINT(20) AUTO_INCREMENT                                 NOT NULL,
  user_id           INT(11)                                                   NOT NULL,
  item_id           INT(11)                                                   NULL,
  urn               VARCHAR(200)                                              NULL,
  item_type         ENUM('dataset', 'dataset_field', 'metric', 'flow', 'urn') NOT NULL DEFAULT 'dataset',
  notification_type ENUM('monthly', 'weekly', 'hourly', 'daily')              NULL     DEFAULT 'weekly',
  created           TIMESTAMP                                                 NULL     DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
)
  ENGINE = InnoDB
  AUTO_INCREMENT = 0
  DEFAULT CHARSET = utf8;

CREATE TABLE favorites (
  user_id    INT(11)   NOT NULL,
  dataset_id INT(11)   NOT NULL,
  created    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, dataset_id)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;

CREATE TABLE user_login_history (
  log_id              INT(11) AUTO_INCREMENT NOT NULL,
  username            VARCHAR(20)            NOT NULL,
  authentication_type VARCHAR(20)            NOT NULL,
  `status`            VARCHAR(20)            NOT NULL,
  message             TEXT                            DEFAULT NULL,
  login_time          TIMESTAMP              NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (log_id)
)
  ENGINE = InnoDB
  DEFAULT CHARSET = utf8;

  

INSERT INTO users (name, email, username, password_digest, password_digest_type, authentication_type) 
VALUES ('wherehows', 'test@123.com', 'wherehows', 'c7b8a7363e537af18548604f8fee93769ae218b3', 'SHA1', 'default');


INSERT INTO dict_dataset (name, `schema`, schema_type, properties, fields, urn, source, storage_type, created_time, modified_time)
VALUES ('FlightCSV', '[{"columnName":"Year","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Quarter","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Month","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DayofMonth","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DayOfWeek","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"FlightDate","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"UniqueCarrier","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"AirlineID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Carrier","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"TailNum","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"FlightNum","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"OriginAirportID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"OriginAirportSeqID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"OriginCityMarketID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Origin","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"OriginCityName","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"OriginState","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"OriginStateFips","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"OriginStateName","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"OriginWac","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DestAirportID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DestAirportSeqID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DestCityMarketID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Dest","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"DestCityName","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"DestState","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"DestStateFips","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DestStateName","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"DestWac","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"CRSDepTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DepTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DepDelay","comment":"","isNullable":"true","dataType":{"type":"float"}},{"columnName":"DepDelayMinutes","comment":"","isNullable":"true","dataType":{"type":"float"}},{"columnName":"DepDel15","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DepartureDelayGroups","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DepTimeBlk","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"TaxiOut","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"WheelsOff","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"WheelsOn","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"TaxiIn","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"CRSArrTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"ArrTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"ArrDelay","comment":"","isNullable":"true","dataType":{"type":"float"}},{"columnName":"ArrDelayMinutes","comment":"","isNullable":"true","dataType":{"type":"float"}},{"columnName":"ArrDel15","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"ArrivalDelayGroups","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"ArrTimeBlk","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Cancelled","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"CancellationCode","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Diverted","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"CRSElapsedTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"ActualElapsedTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"AirTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Flights","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Distance","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DistanceGroup","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"CarrierDelay","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"WeatherDelay","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"NASDelay","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"SecurityDelay","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"LateAircraftDelay","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"FirstDepTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"TotalAddGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"LongestAddGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DivAirportLandings","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DivReachedDest","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DivActualElapsedTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DivArrDelay","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DivDistance","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div1Airport","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Div1AirportID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div1AirportSeqID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div1WheelsOn","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div1TotalGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div1LongestGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div1WheelsOff","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div1TailNum","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Div2Airport","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Div2AirportID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div2AirportSeqID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div2WheelsOn","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div2TotalGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div2LongestGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div2WheelsOff","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div2TailNum","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Div3Airport","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Div3AirportID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div3AirportSeqID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div3WheelsOn","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div3TotalGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div3LongestGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div3WheelsOff","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div3TailNum","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Div4Airport","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Div4AirportID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div4AirportSeqID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div4WheelsOn","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div4TotalGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div4LongestGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div4WheelsOff","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div4TailNum","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Div5Airport","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Div5AirportID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div5AirportSeqID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div5WheelsOn","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div5TotalGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div5LongestGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div5WheelsOff","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div5TailNum","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Comment","comment":"","isNullable":"true","dataType":{"type":"string"}}]', 
'CSV', '{"deployment":"test"}', '[{"columnName":"Year","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Quarter","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Month","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DayofMonth","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DayOfWeek","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"FlightDate","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"UniqueCarrier","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"AirlineID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Carrier","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"TailNum","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"FlightNum","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"OriginAirportID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"OriginAirportSeqID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"OriginCityMarketID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Origin","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"OriginCityName","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"OriginState","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"OriginStateFips","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"OriginStateName","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"OriginWac","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DestAirportID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DestAirportSeqID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DestCityMarketID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Dest","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"DestCityName","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"DestState","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"DestStateFips","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DestStateName","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"DestWac","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"CRSDepTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DepTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DepDelay","comment":"","isNullable":"true","dataType":{"type":"float"}},{"columnName":"DepDelayMinutes","comment":"","isNullable":"true","dataType":{"type":"float"}},{"columnName":"DepDel15","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DepartureDelayGroups","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DepTimeBlk","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"TaxiOut","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"WheelsOff","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"WheelsOn","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"TaxiIn","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"CRSArrTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"ArrTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"ArrDelay","comment":"","isNullable":"true","dataType":{"type":"float"}},{"columnName":"ArrDelayMinutes","comment":"","isNullable":"true","dataType":{"type":"float"}},{"columnName":"ArrDel15","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"ArrivalDelayGroups","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"ArrTimeBlk","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Cancelled","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"CancellationCode","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Diverted","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"CRSElapsedTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"ActualElapsedTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"AirTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Flights","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Distance","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DistanceGroup","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"CarrierDelay","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"WeatherDelay","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"NASDelay","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"SecurityDelay","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"LateAircraftDelay","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"FirstDepTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"TotalAddGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"LongestAddGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DivAirportLandings","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DivReachedDest","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DivActualElapsedTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DivArrDelay","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DivDistance","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div1Airport","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Div1AirportID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div1AirportSeqID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div1WheelsOn","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div1TotalGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div1LongestGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div1WheelsOff","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div1TailNum","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Div2Airport","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Div2AirportID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div2AirportSeqID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div2WheelsOn","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div2TotalGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div2LongestGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div2WheelsOff","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div2TailNum","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Div3Airport","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Div3AirportID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div3AirportSeqID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div3WheelsOn","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div3TotalGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div3LongestGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div3WheelsOff","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div3TailNum","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Div4Airport","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Div4AirportID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div4AirportSeqID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div4WheelsOn","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div4TotalGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div4LongestGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div4WheelsOff","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div4TailNum","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Div5Airport","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Div5AirportID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div5AirportSeqID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div5WheelsOn","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div5TotalGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div5LongestGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div5WheelsOff","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div5TailNum","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Comment","comment":"","isNullable":"true","dataType":{"type":"string"}}]', 
'csv:///test/FlightCSV', 'HDFS', 'Flat File', UNIX_TIMESTAMP(), UNIX_TIMESTAMP());

INSERT INTO dict_dataset (name, `schema`, schema_type, properties, fields, urn, source, storage_type, created_time, modified_time)
VALUES ('Flight', '[{"columnName":"Year","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Quarter","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Month","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DayofMonth","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DayOfWeek","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"FlightDate","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"UniqueCarrier","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"AirlineID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Carrier","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"TailNum","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"FlightNum","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"OriginAirportID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"OriginAirportSeqID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"OriginCityMarketID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Origin","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"OriginCityName","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"OriginState","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"OriginStateFips","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"OriginStateName","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"OriginWac","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DestAirportID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DestAirportSeqID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DestCityMarketID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Dest","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"DestCityName","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"DestState","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"DestStateFips","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DestStateName","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"DestWac","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"CRSDepTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DepTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DepDelay","comment":"","isNullable":"true","dataType":{"type":"float"}},{"columnName":"DepDelayMinutes","comment":"","isNullable":"true","dataType":{"type":"float"}},{"columnName":"DepDel15","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DepartureDelayGroups","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DepTimeBlk","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"TaxiOut","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"WheelsOff","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"WheelsOn","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"TaxiIn","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"CRSArrTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"ArrTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"ArrDelay","comment":"","isNullable":"true","dataType":{"type":"float"}},{"columnName":"ArrDelayMinutes","comment":"","isNullable":"true","dataType":{"type":"float"}},{"columnName":"ArrDel15","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"ArrivalDelayGroups","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"ArrTimeBlk","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Cancelled","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"CancellationCode","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Diverted","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"CRSElapsedTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"ActualElapsedTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"AirTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Flights","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Distance","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DistanceGroup","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"CarrierDelay","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"WeatherDelay","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"NASDelay","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"SecurityDelay","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"LateAircraftDelay","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"FirstDepTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"TotalAddGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"LongestAddGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DivAirportLandings","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DivReachedDest","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DivActualElapsedTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DivArrDelay","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DivDistance","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div1Airport","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Div1AirportID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div1AirportSeqID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div1WheelsOn","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div1TotalGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div1LongestGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div1WheelsOff","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div1TailNum","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Div2Airport","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Div2AirportID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div2AirportSeqID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div2WheelsOn","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div2TotalGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div2LongestGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div2WheelsOff","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div2TailNum","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Div3Airport","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Div3AirportID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div3AirportSeqID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div3WheelsOn","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div3TotalGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div3LongestGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div3WheelsOff","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div3TailNum","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Div4Airport","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Div4AirportID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div4AirportSeqID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div4WheelsOn","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div4TotalGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div4LongestGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div4WheelsOff","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div4TailNum","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Div5Airport","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Div5AirportID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div5AirportSeqID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div5WheelsOn","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div5TotalGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div5LongestGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div5WheelsOff","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div5TailNum","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Comment","comment":"","isNullable":"true","dataType":{"type":"string"}}]', 
'CSV', '{"deployment":"test"}', '[{"columnName":"Year","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Quarter","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Month","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DayofMonth","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DayOfWeek","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"FlightDate","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"UniqueCarrier","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"AirlineID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Carrier","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"TailNum","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"FlightNum","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"OriginAirportID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"OriginAirportSeqID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"OriginCityMarketID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Origin","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"OriginCityName","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"OriginState","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"OriginStateFips","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"OriginStateName","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"OriginWac","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DestAirportID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DestAirportSeqID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DestCityMarketID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Dest","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"DestCityName","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"DestState","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"DestStateFips","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DestStateName","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"DestWac","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"CRSDepTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DepTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DepDelay","comment":"","isNullable":"true","dataType":{"type":"float"}},{"columnName":"DepDelayMinutes","comment":"","isNullable":"true","dataType":{"type":"float"}},{"columnName":"DepDel15","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DepartureDelayGroups","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DepTimeBlk","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"TaxiOut","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"WheelsOff","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"WheelsOn","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"TaxiIn","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"CRSArrTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"ArrTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"ArrDelay","comment":"","isNullable":"true","dataType":{"type":"float"}},{"columnName":"ArrDelayMinutes","comment":"","isNullable":"true","dataType":{"type":"float"}},{"columnName":"ArrDel15","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"ArrivalDelayGroups","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"ArrTimeBlk","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Cancelled","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"CancellationCode","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Diverted","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"CRSElapsedTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"ActualElapsedTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"AirTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Flights","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Distance","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DistanceGroup","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"CarrierDelay","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"WeatherDelay","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"NASDelay","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"SecurityDelay","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"LateAircraftDelay","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"FirstDepTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"TotalAddGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"LongestAddGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DivAirportLandings","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DivReachedDest","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DivActualElapsedTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DivArrDelay","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"DivDistance","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div1Airport","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Div1AirportID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div1AirportSeqID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div1WheelsOn","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div1TotalGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div1LongestGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div1WheelsOff","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div1TailNum","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Div2Airport","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Div2AirportID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div2AirportSeqID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div2WheelsOn","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div2TotalGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div2LongestGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div2WheelsOff","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div2TailNum","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Div3Airport","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Div3AirportID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div3AirportSeqID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div3WheelsOn","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div3TotalGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div3LongestGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div3WheelsOff","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div3TailNum","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Div4Airport","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Div4AirportID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div4AirportSeqID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div4WheelsOn","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div4TotalGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div4LongestGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div4WheelsOff","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div4TailNum","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Div5Airport","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Div5AirportID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div5AirportSeqID","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div5WheelsOn","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div5TotalGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div5LongestGTime","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div5WheelsOff","comment":"","isNullable":"true","dataType":{"type":"int"}},{"columnName":"Div5TailNum","comment":"","isNullable":"true","dataType":{"type":"string"}},{"columnName":"Comment","comment":"","isNullable":"true","dataType":{"type":"string"}}]', 
'kafka:///Flight', 'Kafka', 'Flat File', UNIX_TIMESTAMP(), UNIX_TIMESTAMP());

INSERT INTO dict_dataset (name, `schema`, schema_type, properties, fields, urn, source, storage_type, created_time, modified_time)
VALUES ('Flight', '{"type":"record","name":"Flight","namespace":"KAFKA","doc":"","fields":[{"name":"Year","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Quarter","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Month","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"DayofMonth","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"DayOfWeek","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"FlightDate","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"UniqueCarrier","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"AirlineID","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Carrier","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"TailNum","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"FlightNum","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"OriginAirportID","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"OriginAirportSeqID","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"OriginCityMarketID","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Origin","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"OriginCityName","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"OriginState","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"OriginStateFips","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"OriginStateName","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"OriginWac","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"DestAirportID","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"DestAirportSeqID","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"DestCityMarketID","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Dest","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"DestCityName","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"DestState","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"DestStateFips","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"DestStateName","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"DestWac","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"CRSDepTime","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"DepTime","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"DepDelay","type":["null",{"type":"float","source.type":"float"}],"doc":"","default":null,"source.type":"float"},{"name":"DepDelayMinutes","type":["null",{"type":"float","source.type":"float"}],"doc":"","default":null,"source.type":"float"},{"name":"DepDel15","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"DepartureDelayGroups","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"DepTimeBlk","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"TaxiOut","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"WheelsOff","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"WheelsOn","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"TaxiIn","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"CRSArrTime","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"ArrTime","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"ArrDelay","type":["null",{"type":"float","source.type":"float"}],"doc":"","default":null,"source.type":"float"},{"name":"ArrDelayMinutes","type":["null",{"type":"float","source.type":"float"}],"doc":"","default":null,"source.type":"float"},{"name":"ArrDel15","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"ArrivalDelayGroups","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"ArrTimeBlk","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"Cancelled","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"CancellationCode","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"Diverted","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"CRSElapsedTime","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"ActualElapsedTime","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"AirTime","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Flights","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Distance","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"DistanceGroup","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"CarrierDelay","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"WeatherDelay","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"NASDelay","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"SecurityDelay","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"LateAircraftDelay","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"FirstDepTime","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"TotalAddGTime","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"LongestAddGTime","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"DivAirportLandings","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"DivReachedDest","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"DivActualElapsedTime","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"DivArrDelay","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"DivDistance","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div1Airport","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"Div1AirportID","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div1AirportSeqID","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div1WheelsOn","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div1TotalGTime","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div1LongestGTime","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div1WheelsOff","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div1TailNum","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"Div2Airport","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"Div2AirportID","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div2AirportSeqID","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div2WheelsOn","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div2TotalGTime","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div2LongestGTime","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div2WheelsOff","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div2TailNum","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"Div3Airport","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"Div3AirportID","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div3AirportSeqID","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div3WheelsOn","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div3TotalGTime","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div3LongestGTime","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div3WheelsOff","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div3TailNum","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"Div4Airport","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"Div4AirportID","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div4AirportSeqID","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div4WheelsOn","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div4TotalGTime","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div4LongestGTime","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div4WheelsOff","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div4TailNum","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"Div5Airport","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"Div5AirportID","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div5AirportSeqID","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div5WheelsOn","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div5TotalGTime","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div5LongestGTime","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div5WheelsOff","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div5TailNum","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"Comment","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"}],"source.type":"record"}', 
'AVRO', '{"deployment":"test"}', '[{"name":"Year","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Quarter","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Month","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"DayofMonth","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"DayOfWeek","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"FlightDate","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"UniqueCarrier","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"AirlineID","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Carrier","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"TailNum","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"FlightNum","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"OriginAirportID","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"OriginAirportSeqID","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"OriginCityMarketID","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Origin","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"OriginCityName","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"OriginState","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"OriginStateFips","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"OriginStateName","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"OriginWac","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"DestAirportID","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"DestAirportSeqID","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"DestCityMarketID","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Dest","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"DestCityName","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"DestState","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"DestStateFips","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"DestStateName","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"DestWac","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"CRSDepTime","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"DepTime","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"DepDelay","type":["null",{"type":"float","source.type":"float"}],"doc":"","default":null,"source.type":"float"},{"name":"DepDelayMinutes","type":["null",{"type":"float","source.type":"float"}],"doc":"","default":null,"source.type":"float"},{"name":"DepDel15","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"DepartureDelayGroups","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"DepTimeBlk","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"TaxiOut","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"WheelsOff","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"WheelsOn","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"TaxiIn","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"CRSArrTime","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"ArrTime","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"ArrDelay","type":["null",{"type":"float","source.type":"float"}],"doc":"","default":null,"source.type":"float"},{"name":"ArrDelayMinutes","type":["null",{"type":"float","source.type":"float"}],"doc":"","default":null,"source.type":"float"},{"name":"ArrDel15","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"ArrivalDelayGroups","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"ArrTimeBlk","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"Cancelled","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"CancellationCode","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"Diverted","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"CRSElapsedTime","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"ActualElapsedTime","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"AirTime","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Flights","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Distance","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"DistanceGroup","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"CarrierDelay","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"WeatherDelay","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"NASDelay","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"SecurityDelay","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"LateAircraftDelay","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"FirstDepTime","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"TotalAddGTime","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"LongestAddGTime","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"DivAirportLandings","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"DivReachedDest","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"DivActualElapsedTime","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"DivArrDelay","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"DivDistance","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div1Airport","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"Div1AirportID","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div1AirportSeqID","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div1WheelsOn","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div1TotalGTime","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div1LongestGTime","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div1WheelsOff","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div1TailNum","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"Div2Airport","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"Div2AirportID","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div2AirportSeqID","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div2WheelsOn","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div2TotalGTime","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div2LongestGTime","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div2WheelsOff","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div2TailNum","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"Div3Airport","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"Div3AirportID","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div3AirportSeqID","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div3WheelsOn","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div3TotalGTime","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div3LongestGTime","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div3WheelsOff","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div3TailNum","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"Div4Airport","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"Div4AirportID","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div4AirportSeqID","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div4WheelsOn","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div4TotalGTime","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div4LongestGTime","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div4WheelsOff","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div4TailNum","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"Div5Airport","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"Div5AirportID","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div5AirportSeqID","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div5WheelsOn","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div5TotalGTime","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div5LongestGTime","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div5WheelsOff","type":["null",{"type":"int","source.type":"int"}],"doc":"","default":null,"source.type":"int"},{"name":"Div5TailNum","type":["null",{"type":"string","source.type":"string"}],"doc":"","default":null,"source.type":"string"},{"name":"Comment","type":["null",{"type":"string","source.type":"string"}]', 
'hdfs:///test/FlightAvro', 'HDFS', 'AVRO', UNIX_TIMESTAMP(), UNIX_TIMESTAMP());

INSERT INTO dict_field_detail (dataset_id, fields_layout_id, sort_id, parent_sort_id, field_name, data_type, is_nullable, modified) VALUES
(1, 0, 1, 0, 'Year', 'int', 'Y', NOW()),
(1, 0, 2, 0, 'Quarter', 'int', 'Y', NOW()),
(1, 0, 3, 0, 'Month', 'int', 'Y', NOW()),
(1, 0, 4, 0, 'DayofMonth', 'int', 'Y', NOW()),
(1, 0, 5, 0, 'DayOfWeek', 'int', 'Y', NOW()),
(1, 0, 6, 0, 'FlightDate', 'string', 'Y', NOW()),
(1, 0, 7, 0, 'UniqueCarrier', 'string', 'Y', NOW()),
(1, 0, 8, 0, 'AirlineID', 'int', 'Y', NOW()),
(1, 0, 9, 0, 'Carrier', 'string', 'Y', NOW()),
(1, 0, 10, 0, 'TailNum', 'string', 'Y', NOW()),
(1, 0, 11, 0, 'FlightNum', 'int', 'Y', NOW()),
(1, 0, 12, 0, 'OriginAirportID', 'int', 'Y', NOW()),
(1, 0, 13, 0, 'OriginAirportSeqID', 'int', 'Y', NOW()),
(1, 0, 14, 0, 'OriginCityMarketID', 'int', 'Y', NOW()),
(1, 0, 15, 0, 'Origin', 'string', 'Y', NOW()),
(1, 0, 16, 0, 'OriginCityName', 'string', 'Y', NOW()),
(1, 0, 17, 0, 'OriginState', 'string', 'Y', NOW()),
(1, 0, 18, 0, 'OriginStateFips', 'int', 'Y', NOW()),
(1, 0, 19, 0, 'OriginStateName', 'string', 'Y', NOW()),
(1, 0, 20, 0, 'OriginWac', 'int', 'Y', NOW()),
(1, 0, 21, 0, 'DestAirportID', 'int', 'Y', NOW()),
(1, 0, 22, 0, 'DestAirportSeqID', 'int', 'Y', NOW()),
(1, 0, 23, 0, 'DestCityMarketID', 'int', 'Y', NOW()),
(1, 0, 24, 0, 'Dest', 'string', 'Y', NOW()),
(1, 0, 25, 0, 'DestCityName', 'string', 'Y', NOW()),
(1, 0, 26, 0, 'DestState', 'string', 'Y', NOW()),
(1, 0, 27, 0, 'DestStateFips', 'int', 'Y', NOW()),
(1, 0, 28, 0, 'DestStateName', 'string', 'Y', NOW()),
(1, 0, 29, 0, 'DestWac', 'int', 'Y', NOW()),
(1, 0, 30, 0, 'CRSDepTime', 'int', 'Y', NOW()),
(1, 0, 31, 0, 'DepTime', 'int', 'Y', NOW()),
(1, 0, 32, 0, 'DepDelay', 'float', 'Y', NOW()),
(1, 0, 33, 0, 'DepDelayMinutes', 'float', 'Y', NOW()),
(1, 0, 34, 0, 'DepDel15', 'int', 'Y', NOW()),
(1, 0, 35, 0, 'DepartureDelayGroups', 'int', 'Y', NOW()),
(1, 0, 36, 0, 'DepTimeBlk', 'string', 'Y', NOW()),
(1, 0, 37, 0, 'TaxiOut', 'int', 'Y', NOW()),
(1, 0, 38, 0, 'WheelsOff', 'int', 'Y', NOW()),
(1, 0, 39, 0, 'WheelsOn', 'int', 'Y', NOW()),
(1, 0, 40, 0, 'TaxiIn', 'int', 'Y', NOW()),
(1, 0, 41, 0, 'CRSArrTime', 'int', 'Y', NOW()),
(1, 0, 42, 0, 'ArrTime', 'int', 'Y', NOW()),
(1, 0, 43, 0, 'ArrDelay', 'float', 'Y', NOW()),
(1, 0, 44, 0, 'ArrDelayMinutes', 'float', 'Y', NOW()),
(1, 0, 45, 0, 'ArrDel15', 'int', 'Y', NOW()),
(1, 0, 46, 0, 'ArrivalDelayGroups', 'int', 'Y', NOW()),
(1, 0, 47, 0, 'ArrTimeBlk', 'string', 'Y', NOW()),
(1, 0, 48, 0, 'Cancelled', 'int', 'Y', NOW()),
(1, 0, 49, 0, 'CancellationCode', 'string', 'Y', NOW()),
(1, 0, 50, 0, 'Diverted', 'int', 'Y', NOW()),
(1, 0, 51, 0, 'CRSElapsedTime', 'int', 'Y', NOW()),
(1, 0, 52, 0, 'ActualElapsedTime', 'int', 'Y', NOW()),
(1, 0, 53, 0, 'AirTime', 'int', 'Y', NOW()),
(1, 0, 54, 0, 'Flights', 'int', 'Y', NOW()),
(1, 0, 55, 0, 'Distance', 'int', 'Y', NOW()),
(1, 0, 56, 0, 'DistanceGroup', 'int', 'Y', NOW()),
(1, 0, 57, 0, 'CarrierDelay', 'int', 'Y', NOW()),
(1, 0, 58, 0, 'WeatherDelay', 'int', 'Y', NOW()),
(1, 0, 59, 0, 'NASDelay', 'int', 'Y', NOW()),
(1, 0, 60, 0, 'SecurityDelay', 'int', 'Y', NOW()),
(1, 0, 61, 0, 'LateAircraftDelay', 'int', 'Y', NOW()),
(1, 0, 62, 0, 'FirstDepTime', 'int', 'Y', NOW()),
(1, 0, 63, 0, 'TotalAddGTime', 'int', 'Y', NOW()),
(1, 0, 64, 0, 'LongestAddGTime', 'int', 'Y', NOW()),
(1, 0, 65, 0, 'DivAirportLandings', 'int', 'Y', NOW()),
(1, 0, 66, 0, 'DivReachedDest', 'int', 'Y', NOW()),
(1, 0, 67, 0, 'DivActualElapsedTime', 'int', 'Y', NOW()),
(1, 0, 68, 0, 'DivArrDelay', 'int', 'Y', NOW()),
(1, 0, 69, 0, 'DivDistance', 'int', 'Y', NOW()),
(1, 0, 70, 0, 'Div1Airport', 'string', 'Y', NOW()),
(1, 0, 71, 0, 'Div1AirportID', 'int', 'Y', NOW()),
(1, 0, 72, 0, 'Div1AirportSeqID', 'int', 'Y', NOW()),
(1, 0, 73, 0, 'Div1WheelsOn', 'int', 'Y', NOW()),
(1, 0, 74, 0, 'Div1TotalGTime', 'int', 'Y', NOW()),
(1, 0, 75, 0, 'Div1LongestGTime', 'int', 'Y', NOW()),
(1, 0, 76, 0, 'Div1WheelsOff', 'int', 'Y', NOW()),
(1, 0, 77, 0, 'Div1TailNum', 'string', 'Y', NOW()),
(1, 0, 78, 0, 'Div2Airport', 'string', 'Y', NOW()),
(1, 0, 79, 0, 'Div2AirportID', 'int', 'Y', NOW()),
(1, 0, 80, 0, 'Div2AirportSeqID', 'int', 'Y', NOW()),
(1, 0, 81, 0, 'Div2WheelsOn', 'int', 'Y', NOW()),
(1, 0, 82, 0, 'Div2TotalGTime', 'int', 'Y', NOW()),
(1, 0, 83, 0, 'Div2LongestGTime', 'int', 'Y', NOW()),
(1, 0, 84, 0, 'Div2WheelsOff', 'int', 'Y', NOW()),
(1, 0, 85, 0, 'Div2TailNum', 'string', 'Y', NOW()),
(1, 0, 86, 0, 'Div3Airport', 'string', 'Y', NOW()),
(1, 0, 87, 0, 'Div3AirportID', 'int', 'Y', NOW()),
(1, 0, 88, 0, 'Div3AirportSeqID', 'int', 'Y', NOW()),
(1, 0, 89, 0, 'Div3WheelsOn', 'int', 'Y', NOW()),
(1, 0, 90, 0, 'Div3TotalGTime', 'int', 'Y', NOW()),
(1, 0, 91, 0, 'Div3LongestGTime', 'int', 'Y', NOW()),
(1, 0, 92, 0, 'Div3WheelsOff', 'int', 'Y', NOW()),
(1, 0, 93, 0, 'Div3TailNum', 'string', 'Y', NOW()),
(1, 0, 94, 0, 'Div4Airport', 'string', 'Y', NOW()),
(1, 0, 95, 0, 'Div4AirportID', 'int', 'Y', NOW()),
(1, 0, 96, 0, 'Div4AirportSeqID', 'int', 'Y', NOW()),
(1, 0, 97, 0, 'Div4WheelsOn', 'int', 'Y', NOW()),
(1, 0, 98, 0, 'Div4TotalGTime', 'int', 'Y', NOW()),
(1, 0, 99, 0, 'Div4LongestGTime', 'int', 'Y', NOW()),
(1, 0, 100, 0, 'Div4WheelsOff', 'int', 'Y', NOW()),
(1, 0, 101, 0, 'Div4TailNum', 'string', 'Y', NOW()),
(1, 0, 102, 0, 'Div5Airport', 'string', 'Y', NOW()),
(1, 0, 103, 0, 'Div5AirportID', 'int', 'Y', NOW()),
(1, 0, 104, 0, 'Div5AirportSeqID', 'int', 'Y', NOW()),
(1, 0, 105, 0, 'Div5WheelsOn', 'int', 'Y', NOW()),
(1, 0, 106, 0, 'Div5TotalGTime', 'int', 'Y', NOW()),
(1, 0, 107, 0, 'Div5LongestGTime', 'int', 'Y', NOW()),
(1, 0, 108, 0, 'Div5WheelsOff', 'int', 'Y', NOW()),
(1, 0, 109, 0, 'Div5TailNum', 'string', 'Y', NOW()),
(1, 0, 110, 0, 'Comment', 'string', 'Y', NOW());


INSERT INTO dict_field_detail (dataset_id, fields_layout_id, sort_id, parent_sort_id, field_name, data_type, is_nullable, modified) VALUES
(2, 0, 1, 0, 'Year', 'int', 'Y', NOW()),
(2, 0, 2, 0, 'Quarter', 'int', 'Y', NOW()),
(2, 0, 3, 0, 'Month', 'int', 'Y', NOW()),
(2, 0, 4, 0, 'DayofMonth', 'int', 'Y', NOW()),
(2, 0, 5, 0, 'DayOfWeek', 'int', 'Y', NOW()),
(2, 0, 6, 0, 'FlightDate', 'string', 'Y', NOW()),
(2, 0, 7, 0, 'UniqueCarrier', 'string', 'Y', NOW()),
(2, 0, 8, 0, 'AirlineID', 'int', 'Y', NOW()),
(2, 0, 9, 0, 'Carrier', 'string', 'Y', NOW()),
(2, 0, 10, 0, 'TailNum', 'string', 'Y', NOW()),
(2, 0, 11, 0, 'FlightNum', 'int', 'Y', NOW()),
(2, 0, 12, 0, 'OriginAirportID', 'int', 'Y', NOW()),
(2, 0, 13, 0, 'OriginAirportSeqID', 'int', 'Y', NOW()),
(2, 0, 14, 0, 'OriginCityMarketID', 'int', 'Y', NOW()),
(2, 0, 15, 0, 'Origin', 'string', 'Y', NOW()),
(2, 0, 16, 0, 'OriginCityName', 'string', 'Y', NOW()),
(2, 0, 17, 0, 'OriginState', 'string', 'Y', NOW()),
(2, 0, 18, 0, 'OriginStateFips', 'int', 'Y', NOW()),
(2, 0, 19, 0, 'OriginStateName', 'string', 'Y', NOW()),
(2, 0, 20, 0, 'OriginWac', 'int', 'Y', NOW()),
(2, 0, 21, 0, 'DestAirportID', 'int', 'Y', NOW()),
(2, 0, 22, 0, 'DestAirportSeqID', 'int', 'Y', NOW()),
(2, 0, 23, 0, 'DestCityMarketID', 'int', 'Y', NOW()),
(2, 0, 24, 0, 'Dest', 'string', 'Y', NOW()),
(2, 0, 25, 0, 'DestCityName', 'string', 'Y', NOW()),
(2, 0, 26, 0, 'DestState', 'string', 'Y', NOW()),
(2, 0, 27, 0, 'DestStateFips', 'int', 'Y', NOW()),
(2, 0, 28, 0, 'DestStateName', 'string', 'Y', NOW()),
(2, 0, 29, 0, 'DestWac', 'int', 'Y', NOW()),
(2, 0, 30, 0, 'CRSDepTime', 'int', 'Y', NOW()),
(2, 0, 31, 0, 'DepTime', 'int', 'Y', NOW()),
(2, 0, 32, 0, 'DepDelay', 'float', 'Y', NOW()),
(2, 0, 33, 0, 'DepDelayMinutes', 'float', 'Y', NOW()),
(2, 0, 34, 0, 'DepDel15', 'int', 'Y', NOW()),
(2, 0, 35, 0, 'DepartureDelayGroups', 'int', 'Y', NOW()),
(2, 0, 36, 0, 'DepTimeBlk', 'string', 'Y', NOW()),
(2, 0, 37, 0, 'TaxiOut', 'int', 'Y', NOW()),
(2, 0, 38, 0, 'WheelsOff', 'int', 'Y', NOW()),
(2, 0, 39, 0, 'WheelsOn', 'int', 'Y', NOW()),
(2, 0, 40, 0, 'TaxiIn', 'int', 'Y', NOW()),
(2, 0, 41, 0, 'CRSArrTime', 'int', 'Y', NOW()),
(2, 0, 42, 0, 'ArrTime', 'int', 'Y', NOW()),
(2, 0, 43, 0, 'ArrDelay', 'float', 'Y', NOW()),
(2, 0, 44, 0, 'ArrDelayMinutes', 'float', 'Y', NOW()),
(2, 0, 45, 0, 'ArrDel15', 'int', 'Y', NOW()),
(2, 0, 46, 0, 'ArrivalDelayGroups', 'int', 'Y', NOW()),
(2, 0, 47, 0, 'ArrTimeBlk', 'string', 'Y', NOW()),
(2, 0, 48, 0, 'Cancelled', 'int', 'Y', NOW()),
(2, 0, 49, 0, 'CancellationCode', 'string', 'Y', NOW()),
(2, 0, 50, 0, 'Diverted', 'int', 'Y', NOW()),
(2, 0, 51, 0, 'CRSElapsedTime', 'int', 'Y', NOW()),
(2, 0, 52, 0, 'ActualElapsedTime', 'int', 'Y', NOW()),
(2, 0, 53, 0, 'AirTime', 'int', 'Y', NOW()),
(2, 0, 54, 0, 'Flights', 'int', 'Y', NOW()),
(2, 0, 55, 0, 'Distance', 'int', 'Y', NOW()),
(2, 0, 56, 0, 'DistanceGroup', 'int', 'Y', NOW()),
(2, 0, 57, 0, 'CarrierDelay', 'int', 'Y', NOW()),
(2, 0, 58, 0, 'WeatherDelay', 'int', 'Y', NOW()),
(2, 0, 59, 0, 'NASDelay', 'int', 'Y', NOW()),
(2, 0, 60, 0, 'SecurityDelay', 'int', 'Y', NOW()),
(2, 0, 61, 0, 'LateAircraftDelay', 'int', 'Y', NOW()),
(2, 0, 62, 0, 'FirstDepTime', 'int', 'Y', NOW()),
(2, 0, 63, 0, 'TotalAddGTime', 'int', 'Y', NOW()),
(2, 0, 64, 0, 'LongestAddGTime', 'int', 'Y', NOW()),
(2, 0, 65, 0, 'DivAirportLandings', 'int', 'Y', NOW()),
(2, 0, 66, 0, 'DivReachedDest', 'int', 'Y', NOW()),
(2, 0, 67, 0, 'DivActualElapsedTime', 'int', 'Y', NOW()),
(2, 0, 68, 0, 'DivArrDelay', 'int', 'Y', NOW()),
(2, 0, 69, 0, 'DivDistance', 'int', 'Y', NOW()),
(2, 0, 70, 0, 'Div1Airport', 'string', 'Y', NOW()),
(2, 0, 71, 0, 'Div1AirportID', 'int', 'Y', NOW()),
(2, 0, 72, 0, 'Div1AirportSeqID', 'int', 'Y', NOW()),
(2, 0, 73, 0, 'Div1WheelsOn', 'int', 'Y', NOW()),
(2, 0, 74, 0, 'Div1TotalGTime', 'int', 'Y', NOW()),
(2, 0, 75, 0, 'Div1LongestGTime', 'int', 'Y', NOW()),
(2, 0, 76, 0, 'Div1WheelsOff', 'int', 'Y', NOW()),
(2, 0, 77, 0, 'Div1TailNum', 'string', 'Y', NOW()),
(2, 0, 78, 0, 'Div2Airport', 'string', 'Y', NOW()),
(2, 0, 79, 0, 'Div2AirportID', 'int', 'Y', NOW()),
(2, 0, 80, 0, 'Div2AirportSeqID', 'int', 'Y', NOW()),
(2, 0, 81, 0, 'Div2WheelsOn', 'int', 'Y', NOW()),
(2, 0, 82, 0, 'Div2TotalGTime', 'int', 'Y', NOW()),
(2, 0, 83, 0, 'Div2LongestGTime', 'int', 'Y', NOW()),
(2, 0, 84, 0, 'Div2WheelsOff', 'int', 'Y', NOW()),
(2, 0, 85, 0, 'Div2TailNum', 'string', 'Y', NOW()),
(2, 0, 86, 0, 'Div3Airport', 'string', 'Y', NOW()),
(2, 0, 87, 0, 'Div3AirportID', 'int', 'Y', NOW()),
(2, 0, 88, 0, 'Div3AirportSeqID', 'int', 'Y', NOW()),
(2, 0, 89, 0, 'Div3WheelsOn', 'int', 'Y', NOW()),
(2, 0, 90, 0, 'Div3TotalGTime', 'int', 'Y', NOW()),
(2, 0, 91, 0, 'Div3LongestGTime', 'int', 'Y', NOW()),
(2, 0, 92, 0, 'Div3WheelsOff', 'int', 'Y', NOW()),
(2, 0, 93, 0, 'Div3TailNum', 'string', 'Y', NOW()),
(2, 0, 94, 0, 'Div4Airport', 'string', 'Y', NOW()),
(2, 0, 95, 0, 'Div4AirportID', 'int', 'Y', NOW()),
(2, 0, 96, 0, 'Div4AirportSeqID', 'int', 'Y', NOW()),
(2, 0, 97, 0, 'Div4WheelsOn', 'int', 'Y', NOW()),
(2, 0, 98, 0, 'Div4TotalGTime', 'int', 'Y', NOW()),
(2, 0, 99, 0, 'Div4LongestGTime', 'int', 'Y', NOW()),
(2, 0, 100, 0, 'Div4WheelsOff', 'int', 'Y', NOW()),
(2, 0, 101, 0, 'Div4TailNum', 'string', 'Y', NOW()),
(2, 0, 102, 0, 'Div5Airport', 'string', 'Y', NOW()),
(2, 0, 103, 0, 'Div5AirportID', 'int', 'Y', NOW()),
(2, 0, 104, 0, 'Div5AirportSeqID', 'int', 'Y', NOW()),
(2, 0, 105, 0, 'Div5WheelsOn', 'int', 'Y', NOW()),
(2, 0, 106, 0, 'Div5TotalGTime', 'int', 'Y', NOW()),
(2, 0, 107, 0, 'Div5LongestGTime', 'int', 'Y', NOW()),
(2, 0, 108, 0, 'Div5WheelsOff', 'int', 'Y', NOW()),
(2, 0, 109, 0, 'Div5TailNum', 'string', 'Y', NOW()),
(2, 0, 110, 0, 'Comment', 'string', 'Y', NOW());


INSERT INTO dict_field_detail (dataset_id, fields_layout_id, sort_id, parent_sort_id, field_name, data_type, is_nullable, modified) VALUES
(3, 0, 1, 0, 'Year', 'int', 'Y', NOW()),
(3, 0, 2, 0, 'Quarter', 'int', 'Y', NOW()),
(3, 0, 3, 0, 'Month', 'int', 'Y', NOW()),
(3, 0, 4, 0, 'DayofMonth', 'int', 'Y', NOW()),
(3, 0, 5, 0, 'DayOfWeek', 'int', 'Y', NOW()),
(3, 0, 6, 0, 'FlightDate', 'string', 'Y', NOW()),
(3, 0, 7, 0, 'UniqueCarrier', 'string', 'Y', NOW()),
(3, 0, 8, 0, 'AirlineID', 'int', 'Y', NOW()),
(3, 0, 9, 0, 'Carrier', 'string', 'Y', NOW()),
(3, 0, 10, 0, 'TailNum', 'string', 'Y', NOW()),
(3, 0, 11, 0, 'FlightNum', 'int', 'Y', NOW()),
(3, 0, 12, 0, 'OriginAirportID', 'int', 'Y', NOW()),
(3, 0, 13, 0, 'OriginAirportSeqID', 'int', 'Y', NOW()),
(3, 0, 14, 0, 'OriginCityMarketID', 'int', 'Y', NOW()),
(3, 0, 15, 0, 'Origin', 'string', 'Y', NOW()),
(3, 0, 16, 0, 'OriginCityName', 'string', 'Y', NOW()),
(3, 0, 17, 0, 'OriginState', 'string', 'Y', NOW()),
(3, 0, 18, 0, 'OriginStateFips', 'int', 'Y', NOW()),
(3, 0, 19, 0, 'OriginStateName', 'string', 'Y', NOW()),
(3, 0, 20, 0, 'OriginWac', 'int', 'Y', NOW()),
(3, 0, 21, 0, 'DestAirportID', 'int', 'Y', NOW()),
(3, 0, 22, 0, 'DestAirportSeqID', 'int', 'Y', NOW()),
(3, 0, 23, 0, 'DestCityMarketID', 'int', 'Y', NOW()),
(3, 0, 24, 0, 'Dest', 'string', 'Y', NOW()),
(3, 0, 25, 0, 'DestCityName', 'string', 'Y', NOW()),
(3, 0, 26, 0, 'DestState', 'string', 'Y', NOW()),
(3, 0, 27, 0, 'DestStateFips', 'int', 'Y', NOW()),
(3, 0, 28, 0, 'DestStateName', 'string', 'Y', NOW()),
(3, 0, 29, 0, 'DestWac', 'int', 'Y', NOW()),
(3, 0, 30, 0, 'CRSDepTime', 'int', 'Y', NOW()),
(3, 0, 31, 0, 'DepTime', 'int', 'Y', NOW()),
(3, 0, 32, 0, 'DepDelay', 'float', 'Y', NOW()),
(3, 0, 33, 0, 'DepDelayMinutes', 'float', 'Y', NOW()),
(3, 0, 34, 0, 'DepDel15', 'int', 'Y', NOW()),
(3, 0, 35, 0, 'DepartureDelayGroups', 'int', 'Y', NOW()),
(3, 0, 36, 0, 'DepTimeBlk', 'string', 'Y', NOW()),
(3, 0, 37, 0, 'TaxiOut', 'int', 'Y', NOW()),
(3, 0, 38, 0, 'WheelsOff', 'int', 'Y', NOW()),
(3, 0, 39, 0, 'WheelsOn', 'int', 'Y', NOW()),
(3, 0, 40, 0, 'TaxiIn', 'int', 'Y', NOW()),
(3, 0, 41, 0, 'CRSArrTime', 'int', 'Y', NOW()),
(3, 0, 42, 0, 'ArrTime', 'int', 'Y', NOW()),
(3, 0, 43, 0, 'ArrDelay', 'float', 'Y', NOW()),
(3, 0, 44, 0, 'ArrDelayMinutes', 'float', 'Y', NOW()),
(3, 0, 45, 0, 'ArrDel15', 'int', 'Y', NOW()),
(3, 0, 46, 0, 'ArrivalDelayGroups', 'int', 'Y', NOW()),
(3, 0, 47, 0, 'ArrTimeBlk', 'string', 'Y', NOW()),
(3, 0, 48, 0, 'Cancelled', 'int', 'Y', NOW()),
(3, 0, 49, 0, 'CancellationCode', 'string', 'Y', NOW()),
(3, 0, 50, 0, 'Diverted', 'int', 'Y', NOW()),
(3, 0, 51, 0, 'CRSElapsedTime', 'int', 'Y', NOW()),
(3, 0, 52, 0, 'ActualElapsedTime', 'int', 'Y', NOW()),
(3, 0, 53, 0, 'AirTime', 'int', 'Y', NOW()),
(3, 0, 54, 0, 'Flights', 'int', 'Y', NOW()),
(3, 0, 55, 0, 'Distance', 'int', 'Y', NOW()),
(3, 0, 56, 0, 'DistanceGroup', 'int', 'Y', NOW()),
(3, 0, 57, 0, 'CarrierDelay', 'int', 'Y', NOW()),
(3, 0, 58, 0, 'WeatherDelay', 'int', 'Y', NOW()),
(3, 0, 59, 0, 'NASDelay', 'int', 'Y', NOW()),
(3, 0, 60, 0, 'SecurityDelay', 'int', 'Y', NOW()),
(3, 0, 61, 0, 'LateAircraftDelay', 'int', 'Y', NOW()),
(3, 0, 62, 0, 'FirstDepTime', 'int', 'Y', NOW()),
(3, 0, 63, 0, 'TotalAddGTime', 'int', 'Y', NOW()),
(3, 0, 64, 0, 'LongestAddGTime', 'int', 'Y', NOW()),
(3, 0, 65, 0, 'DivAirportLandings', 'int', 'Y', NOW()),
(3, 0, 66, 0, 'DivReachedDest', 'int', 'Y', NOW()),
(3, 0, 67, 0, 'DivActualElapsedTime', 'int', 'Y', NOW()),
(3, 0, 68, 0, 'DivArrDelay', 'int', 'Y', NOW()),
(3, 0, 69, 0, 'DivDistance', 'int', 'Y', NOW()),
(3, 0, 70, 0, 'Div1Airport', 'string', 'Y', NOW()),
(3, 0, 71, 0, 'Div1AirportID', 'int', 'Y', NOW()),
(3, 0, 72, 0, 'Div1AirportSeqID', 'int', 'Y', NOW()),
(3, 0, 73, 0, 'Div1WheelsOn', 'int', 'Y', NOW()),
(3, 0, 74, 0, 'Div1TotalGTime', 'int', 'Y', NOW()),
(3, 0, 75, 0, 'Div1LongestGTime', 'int', 'Y', NOW()),
(3, 0, 76, 0, 'Div1WheelsOff', 'int', 'Y', NOW()),
(3, 0, 77, 0, 'Div1TailNum', 'string', 'Y', NOW()),
(3, 0, 78, 0, 'Div2Airport', 'string', 'Y', NOW()),
(3, 0, 79, 0, 'Div2AirportID', 'int', 'Y', NOW()),
(3, 0, 80, 0, 'Div2AirportSeqID', 'int', 'Y', NOW()),
(3, 0, 81, 0, 'Div2WheelsOn', 'int', 'Y', NOW()),
(3, 0, 82, 0, 'Div2TotalGTime', 'int', 'Y', NOW()),
(3, 0, 83, 0, 'Div2LongestGTime', 'int', 'Y', NOW()),
(3, 0, 84, 0, 'Div2WheelsOff', 'int', 'Y', NOW()),
(3, 0, 85, 0, 'Div2TailNum', 'string', 'Y', NOW()),
(3, 0, 86, 0, 'Div3Airport', 'string', 'Y', NOW()),
(3, 0, 87, 0, 'Div3AirportID', 'int', 'Y', NOW()),
(3, 0, 88, 0, 'Div3AirportSeqID', 'int', 'Y', NOW()),
(3, 0, 89, 0, 'Div3WheelsOn', 'int', 'Y', NOW()),
(3, 0, 90, 0, 'Div3TotalGTime', 'int', 'Y', NOW()),
(3, 0, 91, 0, 'Div3LongestGTime', 'int', 'Y', NOW()),
(3, 0, 92, 0, 'Div3WheelsOff', 'int', 'Y', NOW()),
(3, 0, 93, 0, 'Div3TailNum', 'string', 'Y', NOW()),
(3, 0, 94, 0, 'Div4Airport', 'string', 'Y', NOW()),
(3, 0, 95, 0, 'Div4AirportID', 'int', 'Y', NOW()),
(3, 0, 96, 0, 'Div4AirportSeqID', 'int', 'Y', NOW()),
(3, 0, 97, 0, 'Div4WheelsOn', 'int', 'Y', NOW()),
(3, 0, 98, 0, 'Div4TotalGTime', 'int', 'Y', NOW()),
(3, 0, 99, 0, 'Div4LongestGTime', 'int', 'Y', NOW()),
(3, 0, 100, 0, 'Div4WheelsOff', 'int', 'Y', NOW()),
(3, 0, 101, 0, 'Div4TailNum', 'string', 'Y', NOW()),
(3, 0, 102, 0, 'Div5Airport', 'string', 'Y', NOW()),
(3, 0, 103, 0, 'Div5AirportID', 'int', 'Y', NOW()),
(3, 0, 104, 0, 'Div5AirportSeqID', 'int', 'Y', NOW()),
(3, 0, 105, 0, 'Div5WheelsOn', 'int', 'Y', NOW()),
(3, 0, 106, 0, 'Div5TotalGTime', 'int', 'Y', NOW()),
(3, 0, 107, 0, 'Div5LongestGTime', 'int', 'Y', NOW()),
(3, 0, 108, 0, 'Div5WheelsOff', 'int', 'Y', NOW()),
(3, 0, 109, 0, 'Div5TailNum', 'string', 'Y', NOW()),
(3, 0, 110, 0, 'Comment', 'string', 'Y', NOW());


INSERT INTO dataset_owner (dataset_id, owner_id, app_id, namespace, owner_type, is_group, is_active, sort_id, created_time, modified_time, dataset_urn, owner_id_type, owner_source, confirmed_by, confirmed_on) VALUES 
(1, 'yiwang', 300, 'urn:li:corpuser:', 'Owner', 'N', 'Y', 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP(), 'csv:///test/FlightCSV', 'USER', 'SCM', 'yiwang', UNIX_TIMESTAMP()),
(1, 'yiwang', 300, 'urn:li:corpuser:', 'Consumer', 'N', 'Y', 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP(), 'csv:///test/FlightCSV', 'USER', 'DB', 'yiwang', UNIX_TIMESTAMP()),
(1, 'nazhang', 300, 'urn:li:corpuser:', 'Producer', 'N', 'Y', 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP(), 'csv:///test/FlightCSV', 'USER', 'SCM', 'yiwang', UNIX_TIMESTAMP()),
(1, 'wherehows', 300, 'urn:li:corpGroup:', 'Owner', 'Y', 'Y', 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP(), 'csv:///test/FlightCSV', 'GROUP', 'UI', null, null);


INSERT INTO dir_external_user_info (app_id, user_id, full_name, display_name, email, is_active, org_hierarchy, org_hierarchy_depth, created_time, modified_time) VALUES
(300, 'yiwang', 'Yi Wang', 'Yi Wang', 'yiwang@abc.com', 'Y', '/jeff/yiwang', 2, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
(300, 'nazhang', 'Na Zhang', 'Na Zhang', 'nazhang@abc.com', 'Y', '/jeff/nazhang', 2, UNIX_TIMESTAMP(), UNIX_TIMESTAMP()),
(300, 'jean', 'Jean', 'Jean', 'jean@abc.com', 'Y', '/jeff/jean', 2, UNIX_TIMESTAMP(), UNIX_TIMESTAMP());

INSERT INTO dir_external_group_user_map (app_id, group_id, sort_id, user_app_id, user_id, created_time, modified_time) VALUES
(301, 'wherehows', 1, 300, 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP());


#SELECT * from dict_dataset;

#SELECT * FROM dict_field_detail;

#SELECT* FROM dataset_owner;

