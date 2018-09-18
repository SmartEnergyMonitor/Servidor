create schema energy;

use energy;




CREATE TABLE `Users` (
	`UserID` INT NOT NULL AUTO_INCREMENT,
	`Username` VARCHAR(50) NOT NULL UNIQUE,
    `Password` VARCHAR(255) NOT NULL,
	`created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`UserID`)
);

insert into Users (Username, Password) values ("admin","password");

CREATE TABLE `Edificio` (
	`EdificioID` int NOT NULL AUTO_INCREMENT,
	`Alias` varchar(100) NOT NULL UNIQUE,
	PRIMARY KEY (`EdificioID`)
);

CREATE TABLE `Quadro` (
	`QuadroID` int NOT NULL AUTO_INCREMENT,
	`Tipo` int NOT NULL,
	`ParentID` int NULL,
	`Alias` varchar(100) NOT NULL,
	PRIMARY KEY (`QuadroID`)
);

CREATE TABLE `EdificioQuadro` (
	`EdificioID` int NOT NULL,
	`QuadroID` int NOT NULL,
    PRIMARY KEY (`EdificioID`,`QuadroID`)
);

CREATE TABLE `Node` (
	`NodeID` int NOT NULL AUTO_INCREMENT,
	`MACAdress` varchar (100) UNIQUE NOT NULL,
	`Alias` varchar(100),
	PRIMARY KEY (`NodeID`)
);

CREATE TABLE `QuadroNode` (
	`QuadroID` int NOT NULL,
	`NodeID` int NOT NULL
);

CREATE TABLE `Sensor` (
	`SensorID` bigint NOT NULL AUTO_INCREMENT,
	`Alias` varchar(100) NOT NULL,
	`Modelo` varchar(100),
	`Amperagem` float NOT NULL,
	`ReadType` int NOT NULL,
	`ConnType` int NOT NULL,
	`I2CAdress` varchar (100) DEFAULT 'None',
	`Canal` varchar (100) NOT NULL,
	`I2CAddTensao` varchar (100),
	`IDFase1` bigint,
	`IDFase2` bigint,
	PRIMARY KEY (`SensorID`)
);

CREATE TABLE `SensorNode` (
	`SensorID` bigint NOT NULL,
	`NodeID` int NOT NULL
);

CREATE TABLE `Leitura` (
	`SensorID` bigint NOT NULL AUTO_INCREMENT,
	`Data` DATETIME DEFAULT CURRENT_TIMESTAMP,
	`Leitura` FLOAT NOT NULL,
	PRIMARY KEY (`SensorID`,`Data`)
);


ALTER TABLE `Quadro` ADD CONSTRAINT `Quadro_fk0` FOREIGN KEY (`ParentID`) REFERENCES `Quadro`(`QuadroID`) ON DELETE CASCADE;

ALTER TABLE `EdificioQuadro` ADD CONSTRAINT `EdificioQuadro_fk0` FOREIGN KEY (`EdificioID`) REFERENCES `Edificio`(`EdificioID`) ON DELETE CASCADE;

ALTER TABLE `EdificioQuadro` ADD CONSTRAINT `EdificioQuadro_fk1` FOREIGN KEY (`QuadroID`) REFERENCES `Quadro`(`QuadroID`) ON DELETE CASCADE;

ALTER TABLE `QuadroNode` ADD CONSTRAINT `QuadroNode_fk0` FOREIGN KEY (`QuadroID`) REFERENCES `Quadro`(`QuadroID`) ON DELETE CASCADE;

ALTER TABLE `QuadroNode` ADD CONSTRAINT `QuadroNode_fk1` FOREIGN KEY (`NodeID`) REFERENCES `Node`(`NodeID`) ON DELETE CASCADE;

ALTER TABLE `Sensor` ADD CONSTRAINT `Sensor_fk0` FOREIGN KEY (`IDFase1`) REFERENCES `Sensor`(`SensorID`) ON DELETE CASCADE;

ALTER TABLE `Sensor` ADD CONSTRAINT `Sensor_fk1` FOREIGN KEY (`IDFase2`) REFERENCES `Sensor`(`SensorID`) ON DELETE CASCADE;

ALTER TABLE `SensorNode` ADD CONSTRAINT `SensorNode_fk0` FOREIGN KEY (`SensorID`) REFERENCES `Sensor`(`SensorID`) ON DELETE CASCADE;

ALTER TABLE `SensorNode` ADD CONSTRAINT `SensorNode_fk1` FOREIGN KEY (`NodeID`) REFERENCES `Node`(`NodeID`) ON DELETE CASCADE;

ALTER TABLE `Leitura` ADD CONSTRAINT `Leitura_fk0` FOREIGN KEY (`SensorID`) REFERENCES `Sensor`(`SensorID`) ON DELETE CASCADE;


