-- MySQL dump 10.13  Distrib 8.0.45, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: quiz_game
-- ------------------------------------------------------
-- Server version	8.0.45

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `categoria`
--

DROP TABLE IF EXISTS `categoria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categoria` (
  `id_categoria` int NOT NULL AUTO_INCREMENT,
  `nombre_categoria` varchar(45) NOT NULL,
  PRIMARY KEY (`id_categoria`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categoria`
--

LOCK TABLES `categoria` WRITE;
/*!40000 ALTER TABLE `categoria` DISABLE KEYS */;
INSERT INTO `categoria` VALUES (1,'Historia'),(2,'Literatura'),(3,'Música'),(4,'Astronomía'),(5,'Tecnología');
/*!40000 ALTER TABLE `categoria` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `partida`
--

DROP TABLE IF EXISTS `partida`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `partida` (
  `id_partida` int NOT NULL AUTO_INCREMENT,
  `id_categoria` int NOT NULL,
  `fecha` datetime DEFAULT NULL,
  PRIMARY KEY (`id_partida`),
  KEY `fk_categoria_idx` (`id_categoria`),
  CONSTRAINT `fk_categoria` FOREIGN KEY (`id_categoria`) REFERENCES `categoria` (`id_categoria`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `partida`
--

LOCK TABLES `partida` WRITE;
/*!40000 ALTER TABLE `partida` DISABLE KEYS */;
INSERT INTO `partida` VALUES (1,2,'2026-04-26 23:20:20');
/*!40000 ALTER TABLE `partida` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `partida_detalle`
--

DROP TABLE IF EXISTS `partida_detalle`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `partida_detalle` (
  `id_detalle` int NOT NULL AUTO_INCREMENT,
  `id_partida` int NOT NULL,
  `id_pregunta` int NOT NULL,
  `fue_correcta` tinyint(1) NOT NULL,
  `id_usuario` int NOT NULL,
  PRIMARY KEY (`id_detalle`),
  KEY `id_partida` (`id_partida`),
  KEY `id_pregunta` (`id_pregunta`),
  KEY `partida_detalle_ibfk_3_idx` (`id_usuario`),
  CONSTRAINT `partida_detalle_ibfk_1` FOREIGN KEY (`id_partida`) REFERENCES `partida` (`id_partida`) ON DELETE CASCADE,
  CONSTRAINT `partida_detalle_ibfk_2` FOREIGN KEY (`id_pregunta`) REFERENCES `pregunta` (`id_pregunta`),
  CONSTRAINT `partida_detalle_ibfk_3` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `partida_detalle`
--

LOCK TABLES `partida_detalle` WRITE;
/*!40000 ALTER TABLE `partida_detalle` DISABLE KEYS */;
/*!40000 ALTER TABLE `partida_detalle` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `partida_usuario`
--

DROP TABLE IF EXISTS `partida_usuario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `partida_usuario` (
  `id_partida` int NOT NULL,
  `id_usuario` int NOT NULL,
  `puntaje_final` int NOT NULL,
  PRIMARY KEY (`id_partida`,`id_usuario`),
  KEY `id_usuario` (`id_usuario`),
  CONSTRAINT `partida_usuario_ibfk_1` FOREIGN KEY (`id_partida`) REFERENCES `partida` (`id_partida`),
  CONSTRAINT `partida_usuario_ibfk_2` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `partida_usuario`
--

LOCK TABLES `partida_usuario` WRITE;
/*!40000 ALTER TABLE `partida_usuario` DISABLE KEYS */;
/*!40000 ALTER TABLE `partida_usuario` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pregunta`
--

DROP TABLE IF EXISTS `pregunta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pregunta` (
  `id_pregunta` int NOT NULL AUTO_INCREMENT,
  `id_categoria` int NOT NULL,
  `texto_pregunta` varchar(455) DEFAULT NULL,
  `tipo_respuesta` enum('texto','imagen') NOT NULL,
  PRIMARY KEY (`id_pregunta`),
  KEY `fk_pregunta_categoria_idx` (`id_categoria`),
  CONSTRAINT `fk_pregunta_categoria` FOREIGN KEY (`id_categoria`) REFERENCES `categoria` (`id_categoria`)
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pregunta`
--

LOCK TABLES `pregunta` WRITE;
/*!40000 ALTER TABLE `pregunta` DISABLE KEYS */;
INSERT INTO `pregunta` VALUES (1,1,'¿En qué año comenzó la Segunda Guerra Mundial?','texto'),(2,1,'¿Quién fue el primer presidente de México?','texto'),(3,1,'¿Qué cultura mesoamericana es famosa por sus calendarios avanzados?','texto'),(4,1,'¿Quién fue el primer hombre en pisar la luna en 1969?','texto'),(5,1,'¿En qué año descubrió América Cristóbal Colón?','texto'),(6,1,'¿Qué imagen muestra a Nelson Mandela?','imagen'),(7,1,'¿Qué imagen corresponde al sacerdote que dio el Grito de Independencia en 1810?','imagen'),(8,1,'¿Quién era el presidente de México en 2010?','imagen'),(9,1,'¿Quién fue el líder de Alemania durante la Segunda Guerra Mundial?','imagen'),(10,1,'¿Cuál de estas pirámides es la Pirámide del Sol?','imagen'),(11,2,'¿Quién escribió Pedro Páramo?','texto'),(12,2,'¿En qué pueblo transcurre la historia de Pedro Páramo?','texto'),(13,2,'¿Quién es el autor de Cien años de soledad?','texto'),(14,2,'¿Quién escribió Don Quijote de la Mancha?','texto'),(15,2,'¿Qué científico escribió el artículo Computing Machinery and Intelligence?','texto'),(16,2,'¿Cuál de estas imágenes corresponde a Don Quijote?','imagen'),(17,2,'¿Cuál de estas imágenes representa al autor de Pedro Páramo?','imagen'),(18,2,'¿Cuál de estas imágenes representa al autor de Pedro Páramo?','imagen'),(19,2,'¿Cuál de estas imágenes corresponde a Alan Turing?','imagen'),(20,2,'¿Cuál de estas imágenes representa el pueblo ficticio de Cien años de soledad?','imagen'),(21,3,'¿Qué cantante es conocido como “El rey del pop”?','texto'),(22,3,'¿Qué banda británica interpretó la canción Bohemian Rhapsody?','texto'),(23,3,'¿Quién compuso La Quinta Sinfonía?','texto'),(24,3,'¿Qué cantante dominicano es conocido como El Rey de la Bachata?','texto'),(25,3,'¿Qué artista lanzó la canción Lose Yourself?','texto'),(26,3,'¿Quién fue el artista principal del Super Bowl 2021?','imagen'),(27,3,'¿Cuál de estos instrumentos pertenece a la música clásica?','imagen'),(28,3,'¿Qué artista se hizo famoso con la canción La Bicicleta?','imagen'),(29,3,'¿Cuál portada corresponde al álbum El Último Tour Del Mundo?','imagen'),(30,3,'¿Quién cantó Waka Waka en el Mundial 2010?','imagen'),(31,4,'¿Cuál es el planeta más grande del sistema solar?','texto'),(32,4,'¿Cuál es el planeta más cercano al Sol?','texto'),(33,4,'¿Cuál es el planeta más lejano del Sol?','texto'),(34,4,'¿Cuál es el sexto planeta desde el Sol?','texto'),(35,4,'¿Cuál es el satélite natural de la Tierra?','texto'),(36,4,'¿Qué imagen corresponde al planeta más grande del sistema solar?','imagen'),(37,4,'¿Cuál de estas imágenes corresponde a la superficie de Mercurio?','imagen'),(38,4,'¿Qué imagen corresponde a nuestra galaxia?','imagen'),(39,4,'¿Qué imagen corresponde al tercer planeta desde el Sol?','imagen'),(40,4,'¿Cuál fase de la Luna se llama cuarto menguante?','imagen'),(41,5,'¿Qué significa RAM?','texto'),(42,5,'¿Quién fabrica las tarjetas gráficas Radeon?','texto'),(43,5,'¿Cuál fue la primera red social importante?','texto'),(44,5,'¿Qué lenguaje se usa para apps iOS?','texto'),(45,5,'¿Quién es el padre de la computación?','texto'),(46,5,'¿Cuál logo corresponde al segundo logo de Apple?','imagen'),(47,5,'¿Cuál empresa NO fabrica CPU?','imagen'),(48,5,'¿Quién es el CEO actual de Apple?','imagen'),(49,5,'¿Qué plataforma popularizó videos de 6 segundos?','imagen'),(50,5,'¿Quién fundó Nvidia?','imagen');
/*!40000 ALTER TABLE `pregunta` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `respuesta`
--

DROP TABLE IF EXISTS `respuesta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `respuesta` (
  `id_respuesta` int NOT NULL AUTO_INCREMENT,
  `id_pregunta` int NOT NULL,
  `texto_respuesta` varchar(255) DEFAULT NULL,
  `ruta_imagen` varchar(255) DEFAULT NULL,
  `es_correcta` tinyint(1) NOT NULL,
  PRIMARY KEY (`id_respuesta`),
  KEY `id_pregunta` (`id_pregunta`),
  CONSTRAINT `respuesta_ibfk_1` FOREIGN KEY (`id_pregunta`) REFERENCES `pregunta` (`id_pregunta`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=201 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `respuesta`
--

LOCK TABLES `respuesta` WRITE;
/*!40000 ALTER TABLE `respuesta` DISABLE KEYS */;
INSERT INTO `respuesta` VALUES (1,1,'1945',NULL,0),(2,1,'1935',NULL,0),(3,1,'1939',NULL,1),(4,1,'1941',NULL,0),(5,2,'Benito Juárez',NULL,0),(6,2,'Porfirio Díaz',NULL,0),(7,2,'Vicente Guerrero',NULL,0),(8,2,'Guadalupe Victoria',NULL,1),(9,3,'Azteca',NULL,0),(10,3,'Maya',NULL,1),(11,3,'Tolteca',NULL,0),(12,3,'Zapoteca',NULL,0),(13,4,'Yuri Gagarin',NULL,0),(14,4,'Buzz Aldrin',NULL,0),(15,4,'Neil Armstrong',NULL,1),(16,4,'Alan Shepard',NULL,0),(17,5,'1482',NULL,0),(18,5,'1492',NULL,1),(19,5,'1502',NULL,0),(20,5,'1495',NULL,0),(21,6,'Nelson Mandela','assets/Cat1/Nelson.jpg',1),(22,6,'Kofi Annan','assets/Cat1/Kofi.jpg',0),(23,6,'Morgan freeman','assets/Cat1/Morgan.jpg',0),(24,6,'Desmond Tutu','assets/Cat1/Desmond.jpg',0),(25,7,'Miguel Hidalgo y Costilla ','assets/Cat1/MiguelHidalgo.jpg',1),(26,7,'José María Morelos ','assets/Cat1/JoseMaria.jpg',0),(27,7,'Ignacio Allende','assets/Cat1/Ignacio.jpg',0),(28,7,'Vicente Guerrero','assets/Cat1/VicenteGuerrero.jpg',0),(29,8,'Vicente Fox','assets/Cat1/VicenteFox.jpg',0),(30,8,'Enrique Peña Nieto','assets/Cat1/Enrique.jpg',0),(31,8,'Felipe Calderon ','assets/Cat1/Felipe.jpg',1),(32,8,'Andres Manuel Lopez Obrador','assets/Cat1/AMLO.jpg',0),(33,9,'Benito Mussolini','assets/Cat1/Benito.jpg',0),(34,9,'Adolf Hitler','assets/Cat1/Hitler.jpg',1),(35,9,'Hirohito','assets/Cat1/Hirohito.jpg',0),(36,9,'Winston Churchill','assets/Cat1/Winston.jpg',0),(37,10,'Pirámide de Djoser ','assets/Cat1/Djoser .jpg',0),(38,10,'Pirámide Meidum','assets/Cat1/Meidum.jpg',0),(39,10,'Pirámide Cestius','assets/Cat1/Cestius.jpg',0),(40,10,'Pirámide del sol','assets/Cat1/Sol.jpg',1),(41,11,'Juan Rulfo',NULL,1),(42,11,'Octavio Paz',NULL,0),(43,11,'Carlos Fuentes',NULL,0),(44,11,'Mario Vargas Llosa',NULL,0),(45,12,'Comala',NULL,1),(46,12,'Macondo',NULL,0),(47,12,'Santa María',NULL,0),(48,12,'Ixtepec',NULL,0),(49,13,'Gabriel García Márquez',NULL,1),(50,13,'Jorge Luis Borges',NULL,0),(51,13,'Julio Cortázar',NULL,0),(52,13,'Pablo Neruda',NULL,0),(53,14,'Miguel de Cervantes',NULL,1),(54,14,'Lope de Vega',NULL,0),(55,14,'Francisco de Quevedo',NULL,0),(56,14,'Calderón de la Barca',NULL,0),(57,15,'Alan Turing',NULL,1),(58,15,'John von Neumann',NULL,0),(59,15,'Claude Shannon',NULL,0),(60,15,'Norbert Wiener',NULL,0),(61,16,'Don Quijote','assets/Cat2/DonQuijote.jpg',1),(62,16,'Sancho Panza','assets/Cat2/SanchoPanza.jpg',0),(63,16,'Dulcinea del Tobosco','assets/Cat2/Dulcinea.jpg',0),(64,16,'Rocinante','assets/Cat2/Rocinante.jpg',0),(65,17,'Juan Rulfo','assets/Cat2/JuanRulfo.jpg',1),(66,17,'Octavio Paz','assets/Cat2/OctavioPaz.jpg',0),(67,17,'Gabriel Garcia Marquez','assets/Cat2/GabrielGarciaMarquez.jpg',1),(68,17,'Carlos Fuentes','assets/Cat2/CarlosFuentes.jpeg',0),(69,18,'Gabriel Garcia Marquez','assets/Cat2/GabrielGarciaMarquez.jpg',0),(70,18,'Mario Vargas Llosa','assets/Cat2/MarioVargasLLosa.jpg',0),(71,18,'Julio Cortazar','assets/Cat2/JulioCortazar.jpg',0),(72,18,'Jorge Luis Borges','assets/Cat2/JorgeLuisBorges.jpg',0),(73,19,'Alan Turing','assets/Cat2/AlanTuring.jpg',1),(74,19,'Albert Einstein','assets/Cat2/AlbertEinstein.jpg',0),(75,19,'Nikola Tesla','assets/Cat2/NikolaTesla.jpg',0),(76,19,'Isaac Newton','assets/Cat2/IsaacNewton.jpg',0),(77,20,'Macondo','assets/Cat2/Macondo.jpg',1),(78,20,'Comala','assets/Cat2/Comala.jpg',0),(79,20,'Buenos Aires','assets/Cat2/BuenosAires.jpg',0),(80,20,'Madrid','assets/Cat2/Madrid.jpg',0),(81,21,'Elvis Presley',NULL,0),(82,21,'Prince Royce',NULL,0),(83,21,'Michael Jackson',NULL,1),(84,21,'Justin Timberlake',NULL,0),(85,22,'The Beatles',NULL,0),(86,22,'Queen',NULL,1),(87,22,'The Who',NULL,0),(88,22,'Oasis',NULL,0),(89,23,'Wolfgang Amadeus Mozart',NULL,0),(90,23,'Johann Sebastian Bach',NULL,0),(91,23,'Ludwig van Beethoven',NULL,1),(92,23,'Franz Schubert',NULL,0),(93,25,'Eminem',NULL,1),(94,25,'50 Cent',NULL,0),(95,25,'Dr. Dre',NULL,0),(96,25,'Snoop Dogg',NULL,0),(97,24,'Prince Royce',NULL,0),(98,24,'Romeo Santos',NULL,1),(99,24,'Juan Luis Guerra',NULL,0),(100,24,'Frank Reyes',NULL,0),(101,26,'Lady gaga','assets/Cat3/LadyGaga.jpg',0),(102,26,'Kendrick Lamar ','assets/Cat3/Kendrick.jpg',0),(103,26,'Jennifer Lopez','assets/Cat3/Jennifer.jpg',0),(104,26,'The Weeknd','assets/Cat3/TheWeekend.jpg',1),(105,27,'Violín','assets/Cat3/Violin.jpg',1),(106,27,'Arpa eléctrica ','assets/Cat3/Arpa.jpg',0),(107,27,'Guitarra','assets/Cat3/Guitarra.jpg',0),(108,27,'Marimba','assets/Cat3/Marimba.jpg',0),(109,28,'Maluma','assets/Cat3/Maluma.jpg',0),(110,28,'Luis Miguel','assets/Cat3/LuisMiguel.jpg',0),(111,28,'Carlos Vives','assets/Cat3/CarlosVives.jpg',1),(112,28,'Ricky Martin','assets/Cat3/Ricky.jpg',0),(113,29,' X 100PRE ','assets/Cat3/X100PRE.jpg',0),(114,29,'YHLQMDLG','assets/Cat3/YHLQMDLG.jpg',0),(115,29,'El Último Tour Del Mundo','assets/Cat3/UltimoTour.jpg',1),(116,29,'Un Verano Sin Ti','assets/Cat3/Verano.jpg',0),(117,30,' Shakira ','assets/Cat3/Shakira.jpg',1),(118,30,'Jennifer Lopez','assets/Cat3/JenniferLopez.jpg',0),(119,30,'Beyonce','assets/Cat3/Beyonce.jpg',0),(120,30,'Rihanna','assets/Cat3/Rihanna.jpg',0),(121,31,'Saturno',NULL,0),(122,31,'Urano',NULL,0),(123,31,'Neptuno',NULL,0),(124,31,'Júpiter',NULL,1),(125,32,'Venus',NULL,0),(126,32,'Tierra',NULL,0),(127,32,'Mercurio',NULL,1),(128,32,'Marte',NULL,0),(129,33,'Neptuno',NULL,1),(130,33,'Saturno',NULL,0),(131,33,'Urano',NULL,0),(132,33,'Júpiter',NULL,0),(133,34,'Júpiter',NULL,0),(134,34,'Saturno',NULL,1),(135,34,'Urano',NULL,0),(136,34,'Neptuno',NULL,0),(137,35,'Andrómeda',NULL,0),(138,35,'La Luna',NULL,1),(139,35,'Sirio',NULL,0),(140,35,'Vía Láctea',NULL,0),(141,36,' Saturno ','assets/Cat4/P6saturno.jpg',0),(142,36,'Júpiter','assets/Cat4/P6jupiter.jpg',1),(143,36,'Neptuno','assets/Cat4/P6neptuno.jpg',0),(144,36,'Urano','assets/Cat4/P6urano.jpg',0),(145,37,' Superficie de Mercurio ','assets/Cat4/supMercurio.jpg',1),(146,37,'Superficie de Marte','assets/Cat4/supMarte.jpg',0),(147,37,'Superficie de la Luna ','assets/Cat4/supLuna.jpg',0),(148,37,'Superficie de venus','assets/Cat4/supVenus.jpg',0),(149,38,'Galaxia de Andrómeda','assets/Cat4/Andromeda.jpg',0),(150,38,'Vía Láctea ','assets/Cat4/ViaLactea.jpg',1),(151,38,'Galaxia del Remolino','assets/Cat4/Remolino.jpg',0),(152,38,'Galaxia del Sombrero','assets/Cat4/Sombrero.jpg',0),(153,39,'Mercurio','assets/Cat4/P9Mercurio.jpg',0),(154,39,'Marte','assets/Cat4/P9Marte.jpg',0),(155,39,'Venus','assets/Cat4/P9Venus.jpg',0),(156,39,'Tierra','assets/Cat4/P9Tierra.jpg',1),(157,40,'Luna creciente','assets/Cat4/Creciente.jpg',0),(158,40,'Cuarto menguante ','assets/Cat4/CuartoMenguante.jpg',1),(159,40,'Luna nueva','assets/Cat4/LunaNueva.jpg',0),(160,40,'Gibosa creciente ','assets/Cat4/Gibosa.jpg',1),(161,41,'Random Access Memory',NULL,1),(162,41,'Rapid Access Machine',NULL,0),(163,41,'Read Access Memory',NULL,0),(164,41,'Real Application Memory',NULL,0),(165,42,'Intel',NULL,0),(166,42,'Nvidia',NULL,0),(167,42,'AMD',NULL,1),(168,42,'Qualcomm',NULL,0),(169,43,'Facebook',NULL,0),(170,43,'MySpace',NULL,1),(171,43,'Twitter',NULL,0),(172,43,'LinkedIn',NULL,0),(173,44,'Python',NULL,0),(174,44,'Java',NULL,0),(175,44,'Swift',NULL,1),(176,44,'Ruby',NULL,0),(177,45,'Alan Turing',NULL,1),(178,45,'Bill Gates',NULL,0),(179,45,'Steve Jobs',NULL,0),(180,45,'Charles Babbage',NULL,0),(181,46,'1976','assets/Cat5/Apple1976.jpg',0),(182,46,'Actual','assets/Cat5/AppleActual.jpg',0),(183,46,'1977','assets/Cat5/Apple1977.jpg',1),(184,46,'1998','assets/Cat5/Apple1998.jpg',0),(185,47,'Intel','assets/Cat5/Intel.jpg',0),(186,47,'AMD','assets/Cat5/AMD.jpg',0),(187,47,'Qualcomm','assets/Cat5/Qualcomm.jpg',0),(188,47,'Razer','assets/Cat5/Razer.jpg',1),(189,48,'Tim Cook','assets/Cat5/Tim.jpg',1),(190,48,'Steve Jobs','assets/Cat5/Steve.jpg',0),(191,48,'Sundar Pichai','assets/Cat5/Sundar.jpg',0),(192,48,'Jeff Bezos','assets/Cat5/Jeff.jpg',0),(193,49,'TikTok','assets/Cat5/TikTok.jpg',0),(194,49,'Vine','assets/Cat5/Vine.jpg',1),(195,49,'YouTube ','assets/Cat5/Youtube.jpg',0),(196,49,'Instagram','assets/Cat5/Instagram.jpg',0),(197,50,'Jensen Huang ','assets/Cat5/Jensen.jpg',1),(198,50,'Elon Musk','assets/Cat5/P10Elon.jpg',0),(199,50,'Mark Zuckerberg','assets/Cat5/Mark.jpg',0),(200,50,'Steve Jobs','assets/Cat5/P10Steve.jpg',0);
/*!40000 ALTER TABLE `respuesta` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuario`
--

DROP TABLE IF EXISTS `usuario`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuario` (
  `id_usuario` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(45) NOT NULL,
  PRIMARY KEY (`id_usuario`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuario`
--

LOCK TABLES `usuario` WRITE;
/*!40000 ALTER TABLE `usuario` DISABLE KEYS */;
/*!40000 ALTER TABLE `usuario` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-26 23:22:13
