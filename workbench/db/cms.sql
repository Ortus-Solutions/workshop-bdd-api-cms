-- MySQL dump 10.13  Distrib 5.7.23, for macos10.13 (x86_64)
--
-- Host: 127.0.0.1    Database: cms
-- ------------------------------------------------------
-- Server version	5.7.24

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
-- Table structure for table `cfmigrations`
--

use `cms`;

DROP TABLE IF EXISTS `cfmigrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cfmigrations` (
  `name` varchar(190) NOT NULL,
  `migration_ran` datetime NOT NULL,
  PRIMARY KEY (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cfmigrations`
--

LOCK TABLES `cfmigrations` WRITE;
/*!40000 ALTER TABLE `cfmigrations` DISABLE KEYS */;
INSERT INTO `cfmigrations` VALUES ('2019_05_19_131027_users','2019-05-19 17:42:49'),('2019_05_19_131456_content','2019-05-19 17:42:49');
/*!40000 ALTER TABLE `cfmigrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `content`
--

DROP TABLE IF EXISTS `content`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `content` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `slug` varchar(255) NOT NULL,
  `title` varchar(255) NOT NULL,
  `body` text NOT NULL,
  `isPublished` tinyint(1) NOT NULL DEFAULT '0',
  `publishedDate` datetime DEFAULT NULL,
  `createdDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modifiedDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `FK_userID` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`),
  KEY `fk_content_FK_userID` (`FK_userID`),
  KEY `idx_publishing` (`isPublished`,`publishedDate`),
  CONSTRAINT `fk_content_FK_userID` FOREIGN KEY (`FK_userID`) REFERENCES `users` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `content`
--

LOCK TABLES `content` WRITE;
/*!40000 ALTER TABLE `content` DISABLE KEYS */;
INSERT INTO `content` VALUES (1,'Box-Girl-Swimming-Pool','brisket alcatra shankle pork chop, turducken picanha','Bacon ipsum dolor amet bacon biltong brisket sirloin kielbasa,hock beef landjaeger boudin alcatra,sausage beef beef ribs pancetta pork chop doner short ribs,brisket alcatra shankle pork chop, turducken picanha,Venison doner leberkas turkey ball tip tongue',0,'2011-10-17 12:57:02','2019-05-19 22:42:49','2019-05-19 22:42:49',2),(2,'Library-Brain-Necklace','hock beef landjaeger boudin alcatra','Bacon ipsum dolor amet bacon biltong brisket sirloin kielbasa,hock beef landjaeger boudin alcatra,sausage beef beef ribs pancetta pork chop doner short ribs,brisket alcatra shankle pork chop, turducken picanha,Venison doner leberkas turkey ball tip tongue',0,'2012-09-30 11:12:10','2019-05-19 22:42:49','2019-05-19 22:42:49',2),(3,'God-Finger-Hieroglyph','Bacon ipsum dolor amet bacon biltong brisket sirloin kielbasa','Bacon ipsum dolor amet bacon biltong brisket sirloin kielbasa,hock beef landjaeger boudin alcatra,sausage beef beef ribs pancetta pork chop doner short ribs,brisket alcatra shankle pork chop, turducken picanha,Venison doner leberkas turkey ball tip tongue',1,'2015-06-15 11:09:44','2019-05-19 22:42:49','2019-05-19 22:42:49',9),(4,'Brain-Teeth-Crystal','hock beef landjaeger boudin alcatra','Bacon ipsum dolor amet bacon biltong brisket sirloin kielbasa,hock beef landjaeger boudin alcatra,sausage beef beef ribs pancetta pork chop doner short ribs,brisket alcatra shankle pork chop, turducken picanha,Venison doner leberkas turkey ball tip tongue',1,'2018-06-18 07:44:08','2019-05-19 22:42:49','2019-05-19 22:42:49',6),(5,'Floodlight-Hieroglyph-Parachute','Bacon ipsum dolor amet bacon biltong brisket sirloin kielbasa','Bacon ipsum dolor amet bacon biltong brisket sirloin kielbasa,hock beef landjaeger boudin alcatra,sausage beef beef ribs pancetta pork chop doner short ribs,brisket alcatra shankle pork chop, turducken picanha,Venison doner leberkas turkey ball tip tongue',1,'2016-03-23 08:30:48','2019-05-19 22:42:49','2019-05-19 22:42:49',5),(6,'Flower-Tapestry-Shop','Venison doner leberkas turkey ball tip tongue','Bacon ipsum dolor amet bacon biltong brisket sirloin kielbasa,hock beef landjaeger boudin alcatra,sausage beef beef ribs pancetta pork chop doner short ribs,brisket alcatra shankle pork chop, turducken picanha,Venison doner leberkas turkey ball tip tongue',0,'2018-05-20 05:57:20','2019-05-19 22:42:49','2019-05-19 22:42:49',2),(7,'Knife-Film-Surveyor','Venison doner leberkas turkey ball tip tongue','Bacon ipsum dolor amet bacon biltong brisket sirloin kielbasa,hock beef landjaeger boudin alcatra,sausage beef beef ribs pancetta pork chop doner short ribs,brisket alcatra shankle pork chop, turducken picanha,Venison doner leberkas turkey ball tip tongue',1,'2012-05-04 01:16:55','2019-05-19 22:42:49','2019-05-19 22:42:49',6),(8,'PaintBrush-Sword-Gloves','Venison doner leberkas turkey ball tip tongue','Bacon ipsum dolor amet bacon biltong brisket sirloin kielbasa,hock beef landjaeger boudin alcatra,sausage beef beef ribs pancetta pork chop doner short ribs,brisket alcatra shankle pork chop, turducken picanha,Venison doner leberkas turkey ball tip tongue',1,'2011-08-10 07:01:25','2019-05-19 22:42:49','2019-05-19 22:42:49',4),(9,'Spoon-School-Staircase','sausage beef beef ribs pancetta pork chop doner short ribs','Bacon ipsum dolor amet bacon biltong brisket sirloin kielbasa,hock beef landjaeger boudin alcatra,sausage beef beef ribs pancetta pork chop doner short ribs,brisket alcatra shankle pork chop, turducken picanha,Venison doner leberkas turkey ball tip tongue',0,'2016-09-29 08:14:12','2019-05-19 22:42:49','2019-05-19 22:42:49',10),(10,'Record-Slave-Crystal','sausage beef beef ribs pancetta pork chop doner short ribs','Bacon ipsum dolor amet bacon biltong brisket sirloin kielbasa,hock beef landjaeger boudin alcatra,sausage beef beef ribs pancetta pork chop doner short ribs,brisket alcatra shankle pork chop, turducken picanha,Venison doner leberkas turkey ball tip tongue',1,'2010-08-18 09:09:16','2019-05-19 22:42:49','2019-05-19 22:42:49',4);
/*!40000 ALTER TABLE `content` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `createdDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `modifiedDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Lucas Padgett','lreyes@google.com','Software1','$2a$12$FE2J7ZLWaI2rSqejAu/84uLy7qlSufQsDsSE1lNNKyA05GG30gr8C','2019-05-19 22:42:49','2019-05-19 22:42:49'),(2,'Maria Bearenstein','rmoneymaker@adobe.com','Table2','$2a$12$FE2J7ZLWaI2rSqejAu/84uLy7qlSufQsDsSE1lNNKyA05GG30gr8C','2019-05-19 22:42:49','2019-05-19 22:42:49'),(3,'Romeo Zelda','erodrigues@msn.com','Ice-cream3','$2a$12$FE2J7ZLWaI2rSqejAu/84uLy7qlSufQsDsSE1lNNKyA05GG30gr8C','2019-05-19 22:42:49','2019-05-19 22:42:49'),(4,'Lucas Marquez','umaggiano@apple.com','Plane4','$2a$12$FE2J7ZLWaI2rSqejAu/84uLy7qlSufQsDsSE1lNNKyA05GG30gr8C','2019-05-19 22:42:49','2019-05-19 22:42:49'),(5,'Ricardo Moneymaker','lrogers@aol.com','Bee5','$2a$12$FE2J7ZLWaI2rSqejAu/84uLy7qlSufQsDsSE1lNNKyA05GG30gr8C','2019-05-19 22:42:49','2019-05-19 22:42:49'),(6,'Nick Reyes','omaggiano@msn.com','Book6','$2a$12$FE2J7ZLWaI2rSqejAu/84uLy7qlSufQsDsSE1lNNKyA05GG30gr8C','2019-05-19 22:42:49','2019-05-19 22:42:49'),(7,'Andy Boudreaux','osanabria@test.com','Triangle7','$2a$12$FE2J7ZLWaI2rSqejAu/84uLy7qlSufQsDsSE1lNNKyA05GG30gr8C','2019-05-19 22:42:49','2019-05-19 22:42:49'),(8,'Alice Moneymaker','aclapton@microsoft.com','Skeleton8','$2a$12$FE2J7ZLWaI2rSqejAu/84uLy7qlSufQsDsSE1lNNKyA05GG30gr8C','2019-05-19 22:42:49','2019-05-19 22:42:49'),(9,'Delores Anderson','amaggiano@msn.com','Ship9','$2a$12$FE2J7ZLWaI2rSqejAu/84uLy7qlSufQsDsSE1lNNKyA05GG30gr8C','2019-05-19 22:42:49','2019-05-19 22:42:49'),(10,'Frank Tobias','obearenstein@gmail.com','Milkshake10','$2a$12$FE2J7ZLWaI2rSqejAu/84uLy7qlSufQsDsSE1lNNKyA05GG30gr8C','2019-05-19 22:42:49','2019-05-19 22:42:49');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'cms'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-05-19 18:44:37
