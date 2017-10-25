
/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `play_evolutions`
--

DROP TABLE IF EXISTS `play_evolutions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `play_evolutions` (
  `id` int(11) NOT NULL,
  `hash` varchar(255) NOT NULL,
  `applied_at` timestamp NOT NULL,
  `apply_script` text,
  `revert_script` text,
  `state` varchar(255) DEFAULT NULL,
  `last_problem` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `yarn_app_heuristic_result`
--

DROP TABLE IF EXISTS `yarn_app_heuristic_result`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `yarn_app_heuristic_result` (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'The application heuristic result id',
  `yarn_app_result_id` varchar(40) NOT NULL,
  `heuristic_class` varchar(255) NOT NULL COMMENT 'The heuristic class name',
  `heuristic_name` varchar(128) NOT NULL COMMENT 'The heuristic name',
  `severity` tinyint(2) unsigned NOT NULL COMMENT 'The heuristic severity',
  `score` mediumint(9) unsigned DEFAULT '0' COMMENT 'The heuristic score for the application',
  PRIMARY KEY (`id`),
  KEY `yarn_app_heuristic_result_i1` (`yarn_app_result_id`),
  KEY `yarn_app_heuristic_result_i2` (`heuristic_name`,`severity`),
  CONSTRAINT `yarn_app_heuristic_result_ibfk_2` FOREIGN KEY (`yarn_app_result_id`) REFERENCES `yarn_app_result` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=509552761 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `yarn_app_heuristic_result_details`
--

DROP TABLE IF EXISTS `yarn_app_heuristic_result_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `yarn_app_heuristic_result_details` (
  `yarn_app_heuristic_result_id` int(11) NOT NULL COMMENT 'The application heuristic result id',
  `name` varchar(128) NOT NULL DEFAULT '' COMMENT 'The analysis detail entry name/key',
  `value` varchar(255) NOT NULL DEFAULT '' COMMENT 'The analysis detail value corresponding to the name',
  `details` text COMMENT 'More information on analysis details. e.g, stacktrace',
  PRIMARY KEY (`yarn_app_heuristic_result_id`,`name`),
  KEY `yarn_app_heuristic_result_details_i1` (`name`),
  CONSTRAINT `yarn_app_heuristic_result_details_f1` FOREIGN KEY (`yarn_app_heuristic_result_id`) REFERENCES `yarn_app_heuristic_result` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `yarn_app_result`
--

DROP TABLE IF EXISTS `yarn_app_result`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `yarn_app_result` (
  `id` varchar(40) NOT NULL COMMENT 'The application id, e.g., application_1236543456321_1234567',
  `name` varchar(100) NOT NULL COMMENT 'The application name',
  `username` char(8) NOT NULL COMMENT 'The user who started the application',
  `queue_name` varchar(50) DEFAULT NULL COMMENT 'The queue the application was submitted to',
  `start_time` bigint(20) NOT NULL DEFAULT '0' COMMENT 'The time in which application started',
  `finish_time` bigint(20) NOT NULL DEFAULT '0' COMMENT 'The time in which application finished',
  `tracking_url` varchar(255) NOT NULL COMMENT 'The web URL that can be used to track the application',
  `job_type` varchar(10) NOT NULL COMMENT 'The Job Type e.g, Pig, Hive, Spark, HadoopJava',
  `severity` tinyint(2) unsigned NOT NULL COMMENT 'The severeness of the application. Ranges from 0(LOW) to 4(CRITICAL)',
  `score` mediumint(9) unsigned DEFAULT '0' COMMENT 'The application score',
  `workflow_depth` tinyint(2) unsigned DEFAULT '0' COMMENT 'The application depth in the scheduled flow. Depth starts from 0',
  `scheduler` varchar(20) DEFAULT NULL COMMENT 'The scheduler which triggered the application',
  `job_name` varchar(255) NOT NULL DEFAULT '' COMMENT 'The name of the job in the flow to which this app belongs',
  `job_exec_id` varchar(800) NOT NULL DEFAULT '' COMMENT 'A unique reference to a specific execution of the job/action(job in the workflow). This should filter all applicationsmapreduce/spark) triggered by the job for a particular execution.',
  `flow_exec_id` varchar(255) NOT NULL DEFAULT '' COMMENT 'A unique reference to a specific flow execution. This should filter all applications fired by a particular flow execution. Note that if the scheduler supports sub-workflows, then this ID should be the super parent flow execution id that triggered the the applications and sub-workflows.',
  `job_def_id` varchar(800) NOT NULL DEFAULT '' COMMENT 'A unique reference to the job in the entire flow independent of the execution. This should filter all the applications(mapreduce/spark) triggered by the job for all the historic executions of that job.',
  `flow_def_id` varchar(800) NOT NULL DEFAULT '' COMMENT 'A unique reference to the entire flow independent of any execution. This should filter all the historic mr jobs belonging to the flow. Note that if your scheduler supports sub-workflows, then this ID should reference the super parent flow that triggered the all the jobs and sub-workflows.',
  `job_exec_url` varchar(800) NOT NULL DEFAULT '' COMMENT 'A url to the job execution on the scheduler',
  `flow_exec_url` varchar(800) NOT NULL DEFAULT '' COMMENT 'A url to the flow execution on the scheduler',
  `job_def_url` varchar(800) NOT NULL DEFAULT '' COMMENT 'A url to the job definition on the scheduler',
  `flow_def_url` varchar(800) NOT NULL DEFAULT '' COMMENT 'A url to the flow definition on the scheduler',
  `resource_used` bigint(20) unsigned NOT NULL DEFAULT '0' COMMENT 'The resources used by the job in MB Seconds',
  `resource_wasted` bigint(20) unsigned NOT NULL DEFAULT '0' COMMENT 'The resources wasted by the job in MB Seconds',
  `total_delay` bigint(20) unsigned NOT NULL DEFAULT '0' COMMENT 'The total delay in starting of mappers',
  PRIMARY KEY (`id`),
  KEY `yarn_app_result_i1` (`finish_time`),
  KEY `yarn_app_result_i2` (`username`,`finish_time`),
  KEY `yarn_app_result_i3` (`job_type`,`username`,`finish_time`),
  KEY `yarn_app_result_i4` (`flow_exec_id`(100)),
  KEY `yarn_app_result_i5` (`job_def_id`(100)),
  KEY `yarn_app_result_i6` (`flow_def_id`(100)),
  KEY `job_exec_id` (`job_exec_id`(100))
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `yarn_app_result_old`
--

DROP TABLE IF EXISTS `yarn_app_result_old`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `yarn_app_result_old` (
  `id` varchar(40) NOT NULL COMMENT 'The application id, e.g., application_1236543456321_1234567',
  `name` varchar(100) NOT NULL COMMENT 'The application name',
  `username` char(8) NOT NULL COMMENT 'The user who started the application',
  `queue_name` varchar(50) DEFAULT NULL COMMENT 'The queue the application was submitted to',
  `start_time` timestamp(3) NOT NULL DEFAULT '0000-00-00 00:00:00.000' COMMENT 'The time in which application started',
  `finish_time` timestamp(3) NOT NULL DEFAULT '0000-00-00 00:00:00.000' COMMENT 'The time in which application finished',
  `tracking_url` varchar(255) NOT NULL COMMENT 'The web URL that can be used to track the application',
  `job_type` varchar(10) NOT NULL COMMENT 'The Job Type e.g, Pig, Hive, Spark, HadoopJava',
  `severity` tinyint(2) unsigned NOT NULL COMMENT 'The severeness of the application. Ranges from 0(LOW) to 4(CRITICAL)',
  `score` mediumint(9) unsigned DEFAULT '0' COMMENT 'The application score',
  `workflow_depth` tinyint(2) unsigned DEFAULT '0' COMMENT 'The application depth in the scheduled flow. Depth starts from 0',
  `scheduler` varchar(20) DEFAULT NULL COMMENT 'The scheduler which triggered the application',
  `job_name` varchar(255) NOT NULL DEFAULT '' COMMENT 'The name of the job in the flow to which this app belongs',
  `job_exec_id` varchar(800) NOT NULL DEFAULT '' COMMENT 'A unique reference to a specific execution of the job/action(job in the workflow). This should filter all applicationsmapreduce/spark) triggered by the job for a particular execution.',
  `flow_exec_id` varchar(255) NOT NULL DEFAULT '' COMMENT 'A unique reference to a specific flow execution. This should filter all applications fired by a particular flow execution. Note that if the scheduler supports sub-workflows, then this ID should be the super parent flow execution id that triggered the the applications and sub-workflows.',
  `job_def_id` varchar(800) NOT NULL DEFAULT '' COMMENT 'A unique reference to the job in the entire flow independent of the execution. This should filter all the applications(mapreduce/spark) triggered by the job for all the historic executions of that job.',
  `flow_def_id` varchar(800) NOT NULL DEFAULT '' COMMENT 'A unique reference to the entire flow independent of any execution. This should filter all the historic mr jobs belonging to the flow. Note that if your scheduler supports sub-workflows, then this ID should reference the super parent flow that triggered the all the jobs and sub-workflows.',
  `job_exec_url` varchar(800) NOT NULL DEFAULT '' COMMENT 'A url to the job execution on the scheduler',
  `flow_exec_url` varchar(800) NOT NULL DEFAULT '' COMMENT 'A url to the flow execution on the scheduler',
  `job_def_url` varchar(800) NOT NULL DEFAULT '' COMMENT 'A url to the job definition on the scheduler',
  `flow_def_url` varchar(800) NOT NULL DEFAULT '' COMMENT 'A url to the flow definition on the scheduler',
  `resource_used` bigint(20) unsigned NOT NULL DEFAULT '0' COMMENT 'The resources used by the job in MB Seconds',
  `resource_wasted` bigint(20) unsigned NOT NULL DEFAULT '0' COMMENT 'The resources wasted by the job in MB Seconds',
  `total_delay` bigint(20) unsigned NOT NULL DEFAULT '0' COMMENT 'The total delay in starting of mappers',
  PRIMARY KEY (`id`),
  KEY `yarn_app_result_i1` (`finish_time`),
  KEY `yarn_app_result_i2` (`username`,`finish_time`),
  KEY `yarn_app_result_i3` (`job_type`,`username`,`finish_time`),
  KEY `yarn_app_result_i4` (`flow_exec_id`(100)),
  KEY `yarn_app_result_i5` (`job_def_id`(100)),
  KEY `yarn_app_result_i6` (`flow_def_id`(100))
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2017-10-24  6:23:16
