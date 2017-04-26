-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- Docker takes care of creating the db for us

-- -----------------------------------------------------
-- Table `Equaliser`.`Series`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Equaliser`.`Series` (
  `SeriesID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `Name` VARCHAR(64) NOT NULL,
  `Description` TEXT NOT NULL,
  `IsShowcase` BIT NOT NULL DEFAULT False,
  PRIMARY KEY (`SeriesID`),
  INDEX `Series_IsShowcase` (`IsShowcase` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Equaliser`.`Countries`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Equaliser`.`Countries` (
  `CountryID` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `Name` VARCHAR(64) NOT NULL,
  `Abbreviation` CHAR(3) NOT NULL,
  `CallingCode` CHAR(3) NOT NULL,
  PRIMARY KEY (`CountryID`),
  UNIQUE INDEX `Name_UNIQUE` (`Name` ASC),
  UNIQUE INDEX `Code_UNIQUE` (`Abbreviation` ASC),
  UNIQUE INDEX `PhoneCode_UNIQUE` (`CallingCode` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Equaliser`.`Venues`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Equaliser`.`Venues` (
  `VenueID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `CountryID` SMALLINT UNSIGNED NOT NULL,
  `Name` VARCHAR(64) NOT NULL,
  `Address` VARCHAR(128) NOT NULL,
  `Postcode` CHAR(8) NOT NULL,
  `AreaCode` CHAR(6) NOT NULL,
  `Phone` CHAR(9) NOT NULL,
  `Location` POINT NOT NULL,
  PRIMARY KEY (`VenueID`),
  INDEX `Venues_CountryID_idx` (`CountryID` ASC),
  CONSTRAINT `Venues_CountryID`
    FOREIGN KEY (`CountryID`)
    REFERENCES `Equaliser`.`Countries` (`CountryID`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Equaliser`.`Fixtures`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Equaliser`.`Fixtures` (
  `FixtureID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `VenueID` INT UNSIGNED NOT NULL,
  `SeriesID` INT UNSIGNED NOT NULL,
  `Start` DATETIME NOT NULL,
  `Finish` DATETIME NOT NULL,
  PRIMARY KEY (`FixtureID`),
  INDEX `Fixtures_VenueID_Venue_idx` (`VenueID` ASC),
  INDEX `Fixtures_SeriesID_idx` (`SeriesID` ASC),
  CONSTRAINT `Fixtures_VenueID`
    FOREIGN KEY (`VenueID`)
    REFERENCES `Equaliser`.`Venues` (`VenueID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `Fixtures_SeriesID`
    FOREIGN KEY (`SeriesID`)
    REFERENCES `Equaliser`.`Series` (`SeriesID`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Equaliser`.`Tiers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Equaliser`.`Tiers` (
  `TierID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `FixtureID` INT UNSIGNED NOT NULL,
  `Name` VARCHAR(32) NOT NULL,
  `Price` DECIMAL(7,2) UNSIGNED NOT NULL,
  `Availability` MEDIUMINT UNSIGNED NOT NULL,
  `ReturnsPolicy` ENUM('ALWAYS','REALLOCATE') NOT NULL DEFAULT 'ALWAYS',
  PRIMARY KEY (`TierID`),
  INDEX `Tiers_FixtureID_idx` (`FixtureID` ASC),
  CONSTRAINT `Tiers_FixtureID`
    FOREIGN KEY (`FixtureID`)
    REFERENCES `Equaliser`.`Fixtures` (`FixtureID`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Equaliser`.`Tags`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Equaliser`.`Tags` (
  `TagID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `Name` VARCHAR(64) NOT NULL,
  PRIMARY KEY (`TagID`),
  UNIQUE INDEX `Name_UNIQUE` (`Name` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Equaliser`.`SeriesTags`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Equaliser`.`SeriesTags` (
  `SeriesID` INT UNSIGNED NOT NULL,
  `TagID` INT UNSIGNED NOT NULL,
  UNIQUE INDEX `SeriesTag` (`SeriesID` ASC, `TagID` ASC),
  UNIQUE INDEX `TagSeries` (`TagID` ASC, `SeriesID` ASC),
  CONSTRAINT `SeriesTags_SeriesID`
    FOREIGN KEY (`SeriesID`)
    REFERENCES `Equaliser`.`Series` (`SeriesID`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `SeriesTags_TagID`
    FOREIGN KEY (`TagID`)
    REFERENCES `Equaliser`.`Tags` (`TagID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Equaliser`.`Images`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Equaliser`.`Images` (
  `ImageID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`ImageID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Equaliser`.`Users`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Equaliser`.`Users` (
  `UserID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `Username` VARCHAR(16) NOT NULL,
  `CountryID` SMALLINT UNSIGNED NOT NULL,
  `Forename` VARCHAR(128) NOT NULL,
  `Surname` VARCHAR(128) NOT NULL,
  `Email` VARCHAR(256) NOT NULL,
  `AreaCode` CHAR(6) NOT NULL,
  `SubscriberNumber` CHAR(6) NOT NULL,
  `Token` BINARY(32) NOT NULL,
  `Password` CHAR(60) CHARACTER SET 'latin1' COLLATE 'latin1_bin' NOT NULL,
  `ImageID` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`UserID`),
  UNIQUE INDEX `Username_UNIQUE` (`Username` ASC),
  UNIQUE INDEX `Token_UNIQUE` (`Token` ASC),
  UNIQUE INDEX `Phone_UNIQUE` (`CountryID` ASC, `AreaCode` ASC, `SubscriberNumber` ASC),
  INDEX `Users_Image_idx` (`ImageID` ASC),
  CONSTRAINT `Users_CountryID`
    FOREIGN KEY (`CountryID`)
    REFERENCES `Equaliser`.`Countries` (`CountryID`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `Users_Image`
    FOREIGN KEY (`ImageID`)
    REFERENCES `Equaliser`.`Images` (`ImageID`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Equaliser`.`Groups`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Equaliser`.`Groups` (
  `GroupID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `UserID` INT UNSIGNED NOT NULL,
  `FixtureID` INT UNSIGNED NOT NULL,
  `Created` DATETIME(6) NOT NULL,
  PRIMARY KEY (`GroupID`),
  INDEX `Groups_UserID_idx` (`UserID` ASC),
  INDEX `Groups_FixtureID_idx` (`FixtureID` ASC),
  CONSTRAINT `Groups_UserID`
    FOREIGN KEY (`UserID`)
    REFERENCES `Equaliser`.`Users` (`UserID`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `Groups_FixtureID`
    FOREIGN KEY (`FixtureID`)
    REFERENCES `Equaliser`.`Fixtures` (`FixtureID`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Equaliser`.`PaymentGroups`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Equaliser`.`PaymentGroups` (
  `PaymentGroupID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `GroupID` INT UNSIGNED NOT NULL,
  `UserID` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`PaymentGroupID`),
  INDEX `PaymentGroups_GroupID_idx` (`GroupID` ASC),
  INDEX `PaymentGroups_UserID_idx` (`UserID` ASC),
  CONSTRAINT `PaymentGroups_GroupID`
    FOREIGN KEY (`GroupID`)
    REFERENCES `Equaliser`.`Groups` (`GroupID`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `PaymentGroups_UserID`
    FOREIGN KEY (`UserID`)
    REFERENCES `Equaliser`.`Users` (`UserID`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Equaliser`.`PaymentGroupAttendees`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Equaliser`.`PaymentGroupAttendees` (
  `PaymentGroupID` INT UNSIGNED NOT NULL,
  `UserID` INT UNSIGNED NOT NULL,
  UNIQUE INDEX `PaymentGroupAttendees_GroupUsers` (`PaymentGroupID` ASC, `UserID` ASC),
  UNIQUE INDEX `PaymentGroupAttendees_UserGroups` (`UserID` ASC, `PaymentGroupID` ASC),
  CONSTRAINT `PaymentGroupAttendees_PaymentGroupID`
    FOREIGN KEY (`PaymentGroupID`)
    REFERENCES `Equaliser`.`PaymentGroups` (`PaymentGroupID`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `PaymentGroupAttendees_UserID`
    FOREIGN KEY (`UserID`)
    REFERENCES `Equaliser`.`Users` (`UserID`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Equaliser`.`GroupTiers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Equaliser`.`GroupTiers` (
  `GroupID` INT UNSIGNED NOT NULL,
  `TierID` INT UNSIGNED NOT NULL,
  `Rank` TINYINT UNSIGNED NOT NULL,
  INDEX `GroupTiers_TierID` (`TierID` ASC),
  UNIQUE INDEX `GroupTiers_GroupTiers` (`GroupID` ASC, `TierID` ASC),
  UNIQUE INDEX `GroupTiers_Group_Rank` (`GroupID` ASC, `Rank` ASC),
  CONSTRAINT `GroupTiers_GroupID`
    FOREIGN KEY (`GroupID`)
    REFERENCES `Equaliser`.`Groups` (`GroupID`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `GroupTiers_TierID`
    FOREIGN KEY (`TierID`)
    REFERENCES `Equaliser`.`Tiers` (`TierID`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Equaliser`.`Offers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Equaliser`.`Offers` (
  `OfferID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `GroupID` INT UNSIGNED NOT NULL,
  `TierID` INT UNSIGNED NOT NULL,
  `Timestamp` TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `Expires` DATETIME NOT NULL,
  `IsReclaimed` BIT NOT NULL DEFAULT False,
  PRIMARY KEY (`OfferID`),
  INDEX `Offers_TierID_idx` (`TierID` ASC),
  UNIQUE INDEX `Offers_GroupTier` (`GroupID` ASC, `TierID` ASC),
  CONSTRAINT `Offers_GroupID`
    FOREIGN KEY (`GroupID`)
    REFERENCES `Equaliser`.`Groups` (`GroupID`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `Offers_TierID`
    FOREIGN KEY (`TierID`)
    REFERENCES `Equaliser`.`Tiers` (`TierID`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Equaliser`.`OfferNotifications`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Equaliser`.`OfferNotifications` (
  `OfferID` INT UNSIGNED NOT NULL,
  `UserID` INT UNSIGNED NOT NULL,
  `Timestamp` TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  INDEX `OfferNotifications_UserID_idx` (`UserID` ASC),
  UNIQUE INDEX `OfferNotifications_OfferUser` (`OfferID` ASC, `UserID` ASC),
  CONSTRAINT `1`
    FOREIGN KEY (`OfferID`)
    REFERENCES `Equaliser`.`Offers` (`OfferID`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `2`
    FOREIGN KEY (`UserID`)
    REFERENCES `Equaliser`.`Users` (`UserID`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Equaliser`.`Transactions`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Equaliser`.`Transactions` (
  `TransactionID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `OfferID` INT UNSIGNED NOT NULL,
  `PaymentGroupID` INT UNSIGNED NOT NULL,
  `Timestamp` TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`TransactionID`),
  INDEX `Transactions_OfferID_idx` (`OfferID` ASC),
  UNIQUE INDEX `Transactions_PaymentGroupOffer` (`PaymentGroupID` ASC, `OfferID` ASC),
  CONSTRAINT `Transactions_OfferID`
    FOREIGN KEY (`OfferID`)
    REFERENCES `Equaliser`.`Offers` (`OfferID`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `Transactions_PaymentGroupID`
    FOREIGN KEY (`PaymentGroupID`)
    REFERENCES `Equaliser`.`PaymentGroups` (`PaymentGroupID`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Equaliser`.`Tickets`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Equaliser`.`Tickets` (
  `TicketID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `TransactionID` INT UNSIGNED NOT NULL,
  `UserID` INT UNSIGNED NOT NULL,
  `NotificationSent` DATETIME(3) NULL,
  PRIMARY KEY (`TicketID`),
  INDEX `Tickets_TransactionID_idx` (`TransactionID` ASC),
  UNIQUE INDEX `Tickets_UserTransaction` (`UserID` ASC, `TransactionID` ASC),
  CONSTRAINT `Tickets_TransactionID`
    FOREIGN KEY (`TransactionID`)
    REFERENCES `Equaliser`.`Transactions` (`TransactionID`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `Tickets_UserID`
    FOREIGN KEY (`UserID`)
    REFERENCES `Equaliser`.`Users` (`UserID`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Equaliser`.`TicketGifts`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Equaliser`.`TicketGifts` (
  `TicketID` INT UNSIGNED NOT NULL,
  `Reveal` DATETIME NOT NULL,
  `Message` VARCHAR(512) NULL,
  UNIQUE INDEX `TicketGifts_TicketID_uq` (`TicketID` ASC),
  CONSTRAINT `TicketGifts_TicketID`
    FOREIGN KEY (`TicketID`)
    REFERENCES `Equaliser`.`Tickets` (`TicketID`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Equaliser`.`Refunds`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Equaliser`.`Refunds` (
  `RefundID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `TicketID` INT UNSIGNED NOT NULL,
  `Requested` TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `Completed` DATETIME NULL,
  PRIMARY KEY (`RefundID`),
  UNIQUE INDEX `TicketID_UNIQUE` (`TicketID` ASC),
  CONSTRAINT `Refunds_TicketID`
    FOREIGN KEY (`TicketID`)
    REFERENCES `Equaliser`.`Tickets` (`TicketID`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Equaliser`.`EphemeralTokens`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Equaliser`.`EphemeralTokens` (
  `UserID` INT UNSIGNED NOT NULL,
  `Token` BINARY(32) NOT NULL,
  `Expires` DATETIME NOT NULL,
  INDEX `UserID_Token` (`UserID` ASC),
  UNIQUE INDEX `Token_UNIQUE` (`Token` ASC, `UserID` ASC),
  CONSTRAINT `EphemeralTokens_UserID`
    FOREIGN KEY (`UserID`)
    REFERENCES `Equaliser`.`Users` (`UserID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Equaliser`.`TwoFactorTokens`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Equaliser`.`TwoFactorTokens` (
  `UserID` INT UNSIGNED NOT NULL,
  `Token` BINARY(32) NOT NULL,
  `Code` CHAR(6) NOT NULL,
  `Sid` CHAR(34) NOT NULL,
  `Expires` DATETIME NOT NULL,
  UNIQUE INDEX `Token_Code` (`UserID` ASC, `Token` ASC, `Code` ASC),
  CONSTRAINT `TwoFactorTokens_Owner`
    FOREIGN KEY (`UserID`)
    REFERENCES `Equaliser`.`Users` (`UserID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Equaliser`.`Sessions`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Equaliser`.`Sessions` (
  `SessionID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `UserID` INT UNSIGNED NOT NULL,
  `Started` TIMESTAMP(3) NOT NULL,
  `Token` BINARY(64) NOT NULL,
  `IsInvalidated` BIT NOT NULL DEFAULT False,
  PRIMARY KEY (`SessionID`),
  INDEX `Sessions_User_idx` (`UserID` ASC),
  UNIQUE INDEX `Token_UNIQUE` (`Token` ASC, `UserID` ASC),
  CONSTRAINT `Sessions_User`
    FOREIGN KEY (`UserID`)
    REFERENCES `Equaliser`.`Users` (`UserID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Equaliser`.`SecurityEventTypes`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Equaliser`.`SecurityEventTypes` (
  `SecurityEventTypeID` TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `Name` VARCHAR(64) NOT NULL,
  PRIMARY KEY (`SecurityEventTypeID`),
  UNIQUE INDEX `SecurityEventTypes_Name` (`Name` ASC))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Equaliser`.`SecurityEvents`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Equaliser`.`SecurityEvents` (
  `SecurityEventID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `SecurityEventTypeID` TINYINT UNSIGNED NOT NULL,
  `SessionID` INT UNSIGNED NOT NULL,
  `IPAddress` BINARY(16) NOT NULL,
  `Timestamp` TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`SecurityEventID`),
  INDEX `SecurityEvent_Type_idx` (`SecurityEventTypeID` ASC),
  INDEX `SecurityEvent_Session_idx` (`SessionID` ASC),
  CONSTRAINT `SecurityEvent_Type`
    FOREIGN KEY (`SecurityEventTypeID`)
    REFERENCES `Equaliser`.`SecurityEventTypes` (`SecurityEventTypeID`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `SecurityEvent_Session`
    FOREIGN KEY (`SessionID`)
    REFERENCES `Equaliser`.`Sessions` (`SessionID`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Equaliser`.`ImageSizes`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Equaliser`.`ImageSizes` (
  `ImageID` INT UNSIGNED NOT NULL,
  `Width` SMALLINT UNSIGNED NOT NULL,
  `Height` SMALLINT UNSIGNED NOT NULL,
  `Sha256` BINARY(32) NOT NULL,
  INDEX `ImageSizes_ImageID` (`ImageID` ASC),
  CONSTRAINT `ImageSizes_ImageID`
    FOREIGN KEY (`ImageID`)
    REFERENCES `Equaliser`.`Images` (`ImageID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `Equaliser`.`SeriesImages`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `Equaliser`.`SeriesImages` (
  `SeriesID` INT UNSIGNED NOT NULL,
  `ImageID` INT UNSIGNED NOT NULL,
  UNIQUE INDEX `SeriesImages_SeriesID_ImageID_uq` (`SeriesID` ASC, `ImageID` ASC),
  INDEX `SeriesImages_ImageID_idx` (`ImageID` ASC),
  CONSTRAINT `SeriesImages_SeriesID`
    FOREIGN KEY (`SeriesID`)
    REFERENCES `Equaliser`.`Series` (`SeriesID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `SeriesImages_ImageID`
    FOREIGN KEY (`ImageID`)
    REFERENCES `Equaliser`.`Images` (`ImageID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- -----------------------------------------------------
-- Data for table `Equaliser`.`Series`
-- -----------------------------------------------------
START TRANSACTION;
USE `Equaliser`;
INSERT INTO `Equaliser`.`Series` (`SeriesID`, `Name`, `Description`, `IsShowcase`) VALUES (1, 'Ed Sheeran: World Tour 2017', 'Ed Sheeran broke through in 2011 after playing literally hundreds of gigs and releasing music independently, when his debut major label single The A Team hit No.3 on the UK chart. The release served as the lead single from Sheeran\'s debut studio album, +, which entered the charts at No.1.\n\nHis second studio album, x, was released in 2014. It also peaked at No.1 and won the Brit Award for Album of the Year. \n\nSheeran has broken records in the live sphere. In July 2015 he took to the stage of Wembley Stadium, solo, to play to 240,000 people over three consecutive sold-out nights. Moreover, he\'s also been involved in an array of spellbinding collaborative performances. In 2012, Sheeran performed at the London Olympics\' closing ceremony alongside members of Pink Floyd and Genesis, and in 2015 he shared the stage with Beyoncé and Gary Clark Jr at that year\'s Grammy tribute for Stevie Wonder.\n\nAfter taking some time off, the now 25-year-old Sheeran has been dominating the charts worldwide with his two latest songs – Shape of You and Castle on the Hill. He\'ll be releasing his genre-defying third studio album, ÷, in early March 2017 and launching a worldwide tour shortly after, with stops in several UK cities in April and early May.', True);
INSERT INTO `Equaliser`.`Series` (`SeriesID`, `Name`, `Description`, `IsShowcase`) VALUES (2, 'The Wimbledon Championships 2017: Day 1', 'The oldest and most prestigious tennis tournament in the world returns to The All England Club on 3rd June.', False);
INSERT INTO `Equaliser`.`Series` (`SeriesID`, `Name`, `Description`, `IsShowcase`) VALUES (3, 'Elbow Tour 2017', 'Tickets to elbow’s 2017 tour dates in the UK and Ireland are now on general sale.', False);
INSERT INTO `Equaliser`.`Series` (`SeriesID`, `Name`, `Description`, `IsShowcase`) VALUES (4, 'Bruno Mars: 24k Magic World Tour', 'Bruno is embarking on his latest tour, delighting fans with his new album 24K Magic, available everywhere now.', True);
INSERT INTO `Equaliser`.`Series` (`SeriesID`, `Name`, `Description`, `IsShowcase`) VALUES (5, 'Take That 2017 Wonderland Tour', 'Take That are going back on tour with Wonderland Live 2017.\n\nWonderland Live 2017 supports the brand new album Wonderland, out March 17 2017.\n\nTickets go on general sale Friday October 28th at 9.30am.', False);
INSERT INTO `Equaliser`.`Series` (`SeriesID`, `Name`, `Description`, `IsShowcase`) VALUES (6, 'Adele - The Finale', 'With worldwide sales of over 21 million copies of her latest album \"25\", the multiple Brit, Grammy, Oscar and Golden Globe winner, will conclude her spectacular tour with two homecoming shows at London\'s iconic Wembley Stadium. Her first world tour will have seen Adele play to over 2 million fans in the UK, Europe, North America, Australia and New Zealand and has been hailed by critics and fans alike.', False);
INSERT INTO `Equaliser`.`Series` (`SeriesID`, `Name`, `Description`, `IsShowcase`) VALUES (7, 'Disney\'s Aladdin', 'Breathtaking sets, astonishing special effects, over 350 lavish costumes and a fabulous cast and orchestra bring the magic of Disney’s Aladdin to life on the West End stage. Directed by Casey Nicholaw (The Book of Mormon, Dreamgirls) and featuring all the songs from the classic Academy Award®-winning film including ‘Friend Like Me’, ‘A Whole New World’ and ‘Arabian Nights’, experience the unmissable ‘theatrical magic’ (Daily Telegraph) that is Aladdin.\n\nThe lead roles of Aladdin and Jasmine are taken by rising British stars Dean John-Wilson (Here Lies Love) and Jade Ewen (In the Heights). Broadway’s Trevor Dion Nicholas has made his London stage debut as the Genie.', True);
INSERT INTO `Equaliser`.`Series` (`SeriesID`, `Name`, `Description`, `IsShowcase`) VALUES (8, 'The Book Of Mormon', 'Gavin Creel and Jared Gertner will play Elder Price and Elder Cunningham in The Book of Mormon, which previews at the Prince of Wales Theatre from 25 February 2013. They are currently leading the company in the Los Angeles production, which has broken all box office records at the Pantages Theatre.  \n\nGavin Creel has previously appeared in the West End as Claude in Hair at the Gielgud Theatre and as Bert in Mary Poppins at the Prince Edward Theatre. Creel received Tony Award® nominations for his roles in the Broadway productions of Hair and Thoroughly Modern Millie.\n\nJared Gertner will make his West End debut in The Book of Mormon. He was a member of the original Tony Award®-winning Broadway company and has previously been seen on stage in Spelling Bee at the Circle in the Square Theatre and in Ordinary Days at the Roundabout Theatre. Gertner has also been seen on TV in Ugly Betty and The Good Wife.\n\nThe Book of Mormon comes from South Park creators Trey Parker and Matt Stone, and Avenue Q co-creator Robert Lopez. The Book of Mormon, winner of nine Tony Awards®, including Best Musical, and the Grammy for Best Musical Theatre album, follows a pair of Mormon boys sent on a mission to a place that’s a long way from Salt Lake City.', False);
INSERT INTO `Equaliser`.`Series` (`SeriesID`, `Name`, `Description`, `IsShowcase`) VALUES (9, 'The Curious Incident of the Dog In the Night-Time', 'The National Theatre’s award-winning production of The Curious Incident of the Dog in the Night-Time is playing at the Gielgud Theatre in London’s West End until 3 June 2017.\n\nWinner of 7 Olivier Awards and 5 Tony Awards® including ‘Best Play’, The Curious Incident of the Dog in the Night-Time brings Mark Haddon’s best-selling novel to thrilling life on stage, adapted by two-time Olivier Award-winning playwright Simon Stephens and directed by Olivier and Tony Award®-winning director Marianne Elliott.', False);
INSERT INTO `Equaliser`.`Series` (`SeriesID`, `Name`, `Description`, `IsShowcase`) VALUES (10, 'Les Misérables', 'Seen by more than 70 million people in 44 countries and in 22 languages around the globe, it is still breaking box-office records everywhere. The original London production celebrated its 30th anniversary on 8 October 2015.\n\nSet against the backdrop of 19th-century France, Les Misérables tells an enthralling story of broken dreams and unrequited love, passion, sacrifice and redemption – a timeless testament to the survival of the human spirit.\n\nEx-convict Jean Valjean is hunted for decades by the ruthless policeman Javert after he breaks parole. When Valjean agrees to care for factory worker Fantine’s young daughter, Cosette, their lives change forever.\n\nFeaturing the songs “I Dreamed A Dream”, “Bring Him Home”, “One Day More” and “On My Own” – Les Misérables is the show of shows.', False);
INSERT INTO `Equaliser`.`Series` (`SeriesID`, `Name`, `Description`, `IsShowcase`) VALUES (11, 'Wicked', 'Based on the acclaimed novel by Gregory Maguire that re-imagined the stories and characters created by L. Frank Baum in ‘The Wonderful Wizard of Oz’, the WICKED musical tells the incredible untold story of an unlikely but profound friendship between two girls who first meet as sorcery students. Their extraordinary adventures in Oz will ultimately see them fulfil their destinies as Glinda The Good and the Wicked Witch of the West. Experience this unforgettable, award-winning musical and discover that you’ve not been told the whole story about the land of Oz...', False);
INSERT INTO `Equaliser`.`Series` (`SeriesID`, `Name`, `Description`, `IsShowcase`) VALUES (12, 'The Clash: Bath Rugby V Leicester Tigers', 'On Saturday 8th April 2017 Bath Rugby will face their fiercest rivals Leicester Tigers at Twickenham Stadium, the legendary home of rugby, in a spectacular event - The Clash. ', False);
INSERT INTO `Equaliser`.`Series` (`SeriesID`, `Name`, `Description`, `IsShowcase`) VALUES (13, 'Aviva Premiership Rugby Final 2017', 'In 2017, we will celebrate the 15th year that the Premiership Rugby Final has decided the champions of England at Twickenham Stadium and to commemorate this important milestone we have compiled the Greatest Final XV below.\n\nThanks to David Flatman, Nick Mullins, Alastair Eykyn, Andrew Baldock, Tom Hamilton & Alan Pearey for choosing their top XV from some of the biggest names in the world game.', False);
INSERT INTO `Equaliser`.`Series` (`SeriesID`, `Name`, `Description`, `IsShowcase`) VALUES (14, 'The Championships, Wimbledon: Day 2', 'Day 2 of the Championship continues first round matches on all courts.', True);
INSERT INTO `Equaliser`.`Series` (`SeriesID`, `Name`, `Description`, `IsShowcase`) VALUES (15, 'Investec Test: England v South Africa Day 1', 'England will once again face off against the South African Cricket team in an eagerly anticipated Investec Test Match from Fri 4 Aug - Tue 8 Aug 2017.\n\nEngland have an impressive record against South Africa in Test Cricket, winning 21 of the 35 Test series between the two nations.\n\nThe Fourth Investec Test match between England and South Africa will be the first time the Proteas have played a Test Match in Manchester since their draw back in 1998, with the hosts eager to win at the home of Lancashire County Cricket Club.', True);

COMMIT;


-- -----------------------------------------------------
-- Data for table `Equaliser`.`Countries`
-- -----------------------------------------------------
START TRANSACTION;
USE `Equaliser`;
INSERT INTO `Equaliser`.`Countries` (`CountryID`, `Name`, `Abbreviation`, `CallingCode`) VALUES (1, 'United Kingdom', 'UK', '44');

COMMIT;


-- -----------------------------------------------------
-- Data for table `Equaliser`.`Venues`
-- -----------------------------------------------------
START TRANSACTION;
USE `Equaliser`;
INSERT INTO `Equaliser`.`Venues` (`VenueID`, `CountryID`, `Name`, `Address`, `Postcode`, `AreaCode`, `Phone`, `Location`) VALUES (1, 1, 'The All England Lawn Tennis and Croquet Club', 'Church Road, Wimbledon, London', 'SW19 5AE', '020', '8944 1066', POINT(51.434292, -0.214490));
INSERT INTO `Equaliser`.`Venues` (`VenueID`, `CountryID`, `Name`, `Address`, `Postcode`, `AreaCode`, `Phone`, `Location`) VALUES (2, 1, 'The O2', 'Peninsula Square, London', 'SE10 0DX', '020', '8463 2000', POINT(51.503041, 0.003149));
INSERT INTO `Equaliser`.`Venues` (`VenueID`, `CountryID`, `Name`, `Address`, `Postcode`, `AreaCode`, `Phone`, `Location`) VALUES (3, 1, 'Barclaycard Arena', 'King Edwards Road, Birmingham', 'B1 2AA', '0121', '7804141', POINT(52.480267, -1.914947));
INSERT INTO `Equaliser`.`Venues` (`VenueID`, `CountryID`, `Name`, `Address`, `Postcode`, `AreaCode`, `Phone`, `Location`) VALUES (4, 1, 'Manchester Arena', 'Victoria Station, Hunts Bank, Manchester', 'M3 1AR', '0161', '9505000', POINT(53.488321, -2.244034));
INSERT INTO `Equaliser`.`Venues` (`VenueID`, `CountryID`, `Name`, `Address`, `Postcode`, `AreaCode`, `Phone`, `Location`) VALUES (5, 1, 'O2 Apollo Manchester', 'Stockport Road, Manchester', 'M12 6AP', '0844', '4777677', POINT(53.469562, -2.222043));
INSERT INTO `Equaliser`.`Venues` (`VenueID`, `CountryID`, `Name`, `Address`, `Postcode`, `AreaCode`, `Phone`, `Location`) VALUES (6, 1, 'Wembley Stadium', 'London', 'HA9 0WS', '0844', '9808001', POINT(51.556054, -0.279551));
INSERT INTO `Equaliser`.`Venues` (`VenueID`, `CountryID`, `Name`, `Address`, `Postcode`, `AreaCode`, `Phone`, `Location`) VALUES (7, 1, 'Prince Edward Theatre', 'Old Compton Street, Soho, London', 'W1D 4HS', '0844', '4825151', POINT(51.513381, -0.130805));
INSERT INTO `Equaliser`.`Venues` (`VenueID`, `CountryID`, `Name`, `Address`, `Postcode`, `AreaCode`, `Phone`, `Location`) VALUES (8, 1, 'Prince Of Wales Theatre', 'Coventry Street, London', 'W1D 6AS', '0844', '4825115', POINT(51.510244, -0.132221));
INSERT INTO `Equaliser`.`Venues` (`VenueID`, `CountryID`, `Name`, `Address`, `Postcode`, `AreaCode`, `Phone`, `Location`) VALUES (9, 1, 'Gielgud Theatre', 'Shaftesbury Avenue, Soho, London', 'W1D 6AR', '0844', '4825130', POINT(51.511708, -0.133050));
INSERT INTO `Equaliser`.`Venues` (`VenueID`, `CountryID`, `Name`, `Address`, `Postcode`, `AreaCode`, `Phone`, `Location`) VALUES (10, 1, 'Queen\'s Theatre', '51 Shaftesbury Avenue, Soho, London', 'W1D 6BA', '0844', '4825160', POINT(51.511841, -0.132618));
INSERT INTO `Equaliser`.`Venues` (`VenueID`, `CountryID`, `Name`, `Address`, `Postcode`, `AreaCode`, `Phone`, `Location`) VALUES (11, 1, 'Apollo Theatre', 'Shaftesbury Avenue, Soho, London', 'W1D 7EZ', '0330', '3334809', POINT(51.511480, -0.133423));
INSERT INTO `Equaliser`.`Venues` (`VenueID`, `CountryID`, `Name`, `Address`, `Postcode`, `AreaCode`, `Phone`, `Location`) VALUES (12, 1, 'Twickenham Stadium', 'Whitton Road, Twickenham', 'TW2 7BA', '0871', '2222120', POINT(51.455949, -0.341548));
INSERT INTO `Equaliser`.`Venues` (`VenueID`, `CountryID`, `Name`, `Address`, `Postcode`, `AreaCode`, `Phone`, `Location`) VALUES (13, 1, 'The Kia Oval', 'Surrey County Cricket Club, Harleyford Street, Kennington, London', 'SE11 5SS', '0844', '3751845', POINT(51.483762, -0.114732));

COMMIT;


-- -----------------------------------------------------
-- Data for table `Equaliser`.`Fixtures`
-- -----------------------------------------------------
START TRANSACTION;
USE `Equaliser`;
INSERT INTO `Equaliser`.`Fixtures` (`FixtureID`, `VenueID`, `SeriesID`, `Start`, `Finish`) VALUES (1, 2, 1, '2017-05-01 18:30:00', '2017-05-01 23:00:00');
INSERT INTO `Equaliser`.`Fixtures` (`FixtureID`, `VenueID`, `SeriesID`, `Start`, `Finish`) VALUES (2, 3, 1, '2017-04-28 17:30:00', '2017-04-28 23:00:00');
INSERT INTO `Equaliser`.`Fixtures` (`FixtureID`, `VenueID`, `SeriesID`, `Start`, `Finish`) VALUES (3, 4, 1, '2017-04-22 18:00:00', '2017-04-22 23:00:00');
INSERT INTO `Equaliser`.`Fixtures` (`FixtureID`, `VenueID`, `SeriesID`, `Start`, `Finish`) VALUES (4, 5, 3, '2017-03-18 19:00:00', '2017-03-18 23:00:00');
INSERT INTO `Equaliser`.`Fixtures` (`FixtureID`, `VenueID`, `SeriesID`, `Start`, `Finish`) VALUES (5, 2, 4, '2017-04-18 18:30:00', '2017-04-18 23:00:00');
INSERT INTO `Equaliser`.`Fixtures` (`FixtureID`, `VenueID`, `SeriesID`, `Start`, `Finish`) VALUES (6, 4, 5, '2017-05-18 18:00:00', '2017-05-18 23:00:00');
INSERT INTO `Equaliser`.`Fixtures` (`FixtureID`, `VenueID`, `SeriesID`, `Start`, `Finish`) VALUES (7, 6, 6, '2017-06-28 18:00:00', '2017-06-28 22:00:00');
INSERT INTO `Equaliser`.`Fixtures` (`FixtureID`, `VenueID`, `SeriesID`, `Start`, `Finish`) VALUES (8, 7, 7, '2017-03-29 19:30:00', '2017-03-29 22:30:00');
INSERT INTO `Equaliser`.`Fixtures` (`FixtureID`, `VenueID`, `SeriesID`, `Start`, `Finish`) VALUES (9, 8, 8, '2017-03-11 14:30:00', '2017-03-11 17:30:00');
INSERT INTO `Equaliser`.`Fixtures` (`FixtureID`, `VenueID`, `SeriesID`, `Start`, `Finish`) VALUES (10, 9, 9, '2017-03-13 19:30:00', '2017-03-13 22:30:00');
INSERT INTO `Equaliser`.`Fixtures` (`FixtureID`, `VenueID`, `SeriesID`, `Start`, `Finish`) VALUES (11, 10, 10, '2017-03-20 19:30:00', '2017-03-20 22:30:00');
INSERT INTO `Equaliser`.`Fixtures` (`FixtureID`, `VenueID`, `SeriesID`, `Start`, `Finish`) VALUES (12, 11, 11, '2017-03-31 19:30:00', '2017-03-31 22:30:00');
INSERT INTO `Equaliser`.`Fixtures` (`FixtureID`, `VenueID`, `SeriesID`, `Start`, `Finish`) VALUES (13, 12, 12, '2017-04-08 14:00:00', '2017-04-08 17:00:00');
INSERT INTO `Equaliser`.`Fixtures` (`FixtureID`, `VenueID`, `SeriesID`, `Start`, `Finish`) VALUES (14, 12, 13, '2017-05-27 14:30:00', '2017-05-27 17:30:00');
INSERT INTO `Equaliser`.`Fixtures` (`FixtureID`, `VenueID`, `SeriesID`, `Start`, `Finish`) VALUES (15, 13, 15, '2017-07-27 11:00:00', '2017-07-27 20:00:00');
INSERT INTO `Equaliser`.`Fixtures` (`FixtureID`, `VenueID`, `SeriesID`, `Start`, `Finish`) VALUES (16, 1, 2, '2017-07-01 10:00:00', '2017-07-01 19:00:00');
INSERT INTO `Equaliser`.`Fixtures` (`FixtureID`, `VenueID`, `SeriesID`, `Start`, `Finish`) VALUES (17, 1, 2, '2017-07-01 10:00:00', '2017-07-01 19:00:00');
INSERT INTO `Equaliser`.`Fixtures` (`FixtureID`, `VenueID`, `SeriesID`, `Start`, `Finish`) VALUES (18, 1, 2, '2017-07-01 10:00:00', '2017-07-01 19:00:00');
INSERT INTO `Equaliser`.`Fixtures` (`FixtureID`, `VenueID`, `SeriesID`, `Start`, `Finish`) VALUES (19, 1, 2, '2017-07-01 10:00:00', '2017-07-01 19:00:00');
INSERT INTO `Equaliser`.`Fixtures` (`FixtureID`, `VenueID`, `SeriesID`, `Start`, `Finish`) VALUES (20, 1, 2, '2017-07-01 10:00:00', '2017-07-01 19:00:00');
INSERT INTO `Equaliser`.`Fixtures` (`FixtureID`, `VenueID`, `SeriesID`, `Start`, `Finish`) VALUES (21, 1, 14, '2017-07-02 10:00:00', '2017-07-02 19:00:00');
INSERT INTO `Equaliser`.`Fixtures` (`FixtureID`, `VenueID`, `SeriesID`, `Start`, `Finish`) VALUES (22, 1, 14, '2017-07-02 10:00:00', '2017-07-02 19:00:00');
INSERT INTO `Equaliser`.`Fixtures` (`FixtureID`, `VenueID`, `SeriesID`, `Start`, `Finish`) VALUES (23, 1, 14, '2017-07-02 10:00:00', '2017-07-02 19:00:00');
INSERT INTO `Equaliser`.`Fixtures` (`FixtureID`, `VenueID`, `SeriesID`, `Start`, `Finish`) VALUES (24, 1, 14, '2017-07-02 10:00:00', '2017-07-02 19:00:00');
INSERT INTO `Equaliser`.`Fixtures` (`FixtureID`, `VenueID`, `SeriesID`, `Start`, `Finish`) VALUES (25, 1, 14, '2017-07-02 10:00:00', '2017-07-02 19:00:00');

COMMIT;


-- -----------------------------------------------------
-- Data for table `Equaliser`.`Tiers`
-- -----------------------------------------------------
START TRANSACTION;
USE `Equaliser`;
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (1, 1, 'Standing', 80.00, 0, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (2, 1, 'Floor Seating', 60.00, 0, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (3, 1, 'Lower Circle', 60.00, 5000, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (4, 1, 'Upper Circle', 75.00, 0, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (5, 2, 'Standing', 75.00, 0, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (6, 2, 'Floor Seating', 60.00, 1800, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (7, 2, 'Lower Tier', 70.00, 0, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (8, 2, 'Upper Tier', 70.00, 0, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (9, 3, 'Standing', 80.00, 6000, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (10, 3, 'Floor Seating', 60.00, 0, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (11, 3, 'Lower Circle', 60.00, 6000, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (12, 3, 'Upper Circle', 70.00, 7000, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (13, 4, 'Standing', 40.00, 1000, 'ALWAYS');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (14, 4, 'Front Circle', 45.00, 1000, 'ALWAYS');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (15, 4, 'Rear Circle', 45.00, 1500, 'ALWAYS');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (16, 5, 'Standing', 60.00, 8000, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (17, 5, 'Lower Tier Front', 90.00, 1000, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (18, 5, 'Lower Tier Sides', 75.00, 4000, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (19, 5, 'Upper Tier', 55.00, 7000, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (20, 6, 'Standing', 90.00, 6000, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (21, 6, 'Lower Tier', 80.00, 6000, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (22, 6, 'Upper Tier', 70.00, 8000, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (23, 7, 'Standing', 85.00, 20000, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (24, 7, 'Lower Tier', 80.00, 15000, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (25, 7, 'Middle Tier', 75.00, 25000, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (26, 7, 'Upper Tier', 70.00, 30000, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (27, 8, 'Grand Circle', 75.00, 500, 'ALWAYS');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (28, 8, 'Dress Circle', 65.00, 500, 'ALWAYS');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (29, 8, 'Stalls', 80.00, 650, 'ALWAYS');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (30, 9, 'Stalls', 80.00, 500, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (31, 9, 'Circle', 70.00, 500, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (32, 9, 'Box', 150.00, 32, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (33, 9, 'Standing Rear', 50.00, 128, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (34, 10, 'Grand Circle', 25.00, 286, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (35, 10, 'Dress Circle', 60.00, 350, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (36, 10, 'Stalls', 90.00, 350, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (37, 11, 'Stalls', 120.00, 350, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (38, 11, 'Dress Circle', 100.00, 350, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (39, 11, 'Upper Circle', 90.00, 374, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (40, 12, 'Stalls', 120.00, 300, 'ALWAYS');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (41, 12, 'Dress Circle', 100.00, 300, 'ALWAYS');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (42, 12, 'Upper Circle', 80.00, 175, 'ALWAYS');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (43, 13, 'Section L', 10.00, 25000, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (44, 13, 'Section M', 20.00, 27000, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (45, 13, 'Section U', 30.00, 30000, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (46, 14, 'Section L', 15.00, 25000, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (47, 14, 'Section M', 25.00, 27000, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (48, 14, 'Section U', 35.00, 30000, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (49, 15, 'Standard', 60.00, 17000, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (50, 15, 'OCS Stand', 80.00, 6000, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (51, 15, 'Hospitality', 250.00, 3556, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (52, 16, 'Centre Court', 56.00, 0, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (53, 17, 'No.1 Court', 45.00, 11360, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (54, 18, 'No.2 Court', 41.00, 4000, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (55, 19, 'No.3 Court', 41.00, 0, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (56, 20, 'Grounds', 25.00, 2000, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (57, 21, 'Centre Court', 56.00, 0, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (58, 22, 'No.1 Court', 45.00, 0, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (59, 23, 'No.2 Court', 41.00, 4000, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (60, 24, 'No.3 Court', 41.00, 0, 'REALLOCATE');
INSERT INTO `Equaliser`.`Tiers` (`TierID`, `FixtureID`, `Name`, `Price`, `Availability`, `ReturnsPolicy`) VALUES (61, 25, 'Grounds', 25.00, 2000, 'REALLOCATE');

COMMIT;


-- -----------------------------------------------------
-- Data for table `Equaliser`.`Tags`
-- -----------------------------------------------------
START TRANSACTION;
USE `Equaliser`;
INSERT INTO `Equaliser`.`Tags` (`TagID`, `Name`) VALUES (1, 'Music');
INSERT INTO `Equaliser`.`Tags` (`TagID`, `Name`) VALUES (2, 'Theatre');
INSERT INTO `Equaliser`.`Tags` (`TagID`, `Name`) VALUES (3, 'Sports');
INSERT INTO `Equaliser`.`Tags` (`TagID`, `Name`) VALUES (4, 'Singer-songwriter');
INSERT INTO `Equaliser`.`Tags` (`TagID`, `Name`) VALUES (5, 'Tennis');
INSERT INTO `Equaliser`.`Tags` (`TagID`, `Name`) VALUES (6, 'Comedy');
INSERT INTO `Equaliser`.`Tags` (`TagID`, `Name`) VALUES (7, 'Musical');
INSERT INTO `Equaliser`.`Tags` (`TagID`, `Name`) VALUES (8, 'Rugby');
INSERT INTO `Equaliser`.`Tags` (`TagID`, `Name`) VALUES (9, 'Cricket');

COMMIT;


-- -----------------------------------------------------
-- Data for table `Equaliser`.`SeriesTags`
-- -----------------------------------------------------
START TRANSACTION;
USE `Equaliser`;
INSERT INTO `Equaliser`.`SeriesTags` (`SeriesID`, `TagID`) VALUES (1, 1);
INSERT INTO `Equaliser`.`SeriesTags` (`SeriesID`, `TagID`) VALUES (1, 4);
INSERT INTO `Equaliser`.`SeriesTags` (`SeriesID`, `TagID`) VALUES (2, 3);
INSERT INTO `Equaliser`.`SeriesTags` (`SeriesID`, `TagID`) VALUES (2, 5);
INSERT INTO `Equaliser`.`SeriesTags` (`SeriesID`, `TagID`) VALUES (3, 1);
INSERT INTO `Equaliser`.`SeriesTags` (`SeriesID`, `TagID`) VALUES (4, 1);
INSERT INTO `Equaliser`.`SeriesTags` (`SeriesID`, `TagID`) VALUES (4, 4);
INSERT INTO `Equaliser`.`SeriesTags` (`SeriesID`, `TagID`) VALUES (5, 1);
INSERT INTO `Equaliser`.`SeriesTags` (`SeriesID`, `TagID`) VALUES (6, 1);
INSERT INTO `Equaliser`.`SeriesTags` (`SeriesID`, `TagID`) VALUES (6, 4);
INSERT INTO `Equaliser`.`SeriesTags` (`SeriesID`, `TagID`) VALUES (7, 2);
INSERT INTO `Equaliser`.`SeriesTags` (`SeriesID`, `TagID`) VALUES (7, 7);
INSERT INTO `Equaliser`.`SeriesTags` (`SeriesID`, `TagID`) VALUES (8, 2);
INSERT INTO `Equaliser`.`SeriesTags` (`SeriesID`, `TagID`) VALUES (8, 6);
INSERT INTO `Equaliser`.`SeriesTags` (`SeriesID`, `TagID`) VALUES (8, 7);
INSERT INTO `Equaliser`.`SeriesTags` (`SeriesID`, `TagID`) VALUES (9, 2);
INSERT INTO `Equaliser`.`SeriesTags` (`SeriesID`, `TagID`) VALUES (10, 2);
INSERT INTO `Equaliser`.`SeriesTags` (`SeriesID`, `TagID`) VALUES (10, 7);
INSERT INTO `Equaliser`.`SeriesTags` (`SeriesID`, `TagID`) VALUES (11, 2);
INSERT INTO `Equaliser`.`SeriesTags` (`SeriesID`, `TagID`) VALUES (11, 7);
INSERT INTO `Equaliser`.`SeriesTags` (`SeriesID`, `TagID`) VALUES (12, 3);
INSERT INTO `Equaliser`.`SeriesTags` (`SeriesID`, `TagID`) VALUES (12, 8);
INSERT INTO `Equaliser`.`SeriesTags` (`SeriesID`, `TagID`) VALUES (13, 3);
INSERT INTO `Equaliser`.`SeriesTags` (`SeriesID`, `TagID`) VALUES (13, 8);
INSERT INTO `Equaliser`.`SeriesTags` (`SeriesID`, `TagID`) VALUES (14, 3);
INSERT INTO `Equaliser`.`SeriesTags` (`SeriesID`, `TagID`) VALUES (14, 5);
INSERT INTO `Equaliser`.`SeriesTags` (`SeriesID`, `TagID`) VALUES (15, 3);
INSERT INTO `Equaliser`.`SeriesTags` (`SeriesID`, `TagID`) VALUES (15, 9);

COMMIT;


-- -----------------------------------------------------
-- Data for table `Equaliser`.`Images`
-- -----------------------------------------------------
START TRANSACTION;
USE `Equaliser`;
INSERT INTO `Equaliser`.`Images` (`ImageID`) VALUES (1);
INSERT INTO `Equaliser`.`Images` (`ImageID`) VALUES (2);
INSERT INTO `Equaliser`.`Images` (`ImageID`) VALUES (3);
INSERT INTO `Equaliser`.`Images` (`ImageID`) VALUES (4);
INSERT INTO `Equaliser`.`Images` (`ImageID`) VALUES (5);
INSERT INTO `Equaliser`.`Images` (`ImageID`) VALUES (6);
INSERT INTO `Equaliser`.`Images` (`ImageID`) VALUES (7);
INSERT INTO `Equaliser`.`Images` (`ImageID`) VALUES (8);
INSERT INTO `Equaliser`.`Images` (`ImageID`) VALUES (9);
INSERT INTO `Equaliser`.`Images` (`ImageID`) VALUES (10);
INSERT INTO `Equaliser`.`Images` (`ImageID`) VALUES (11);
INSERT INTO `Equaliser`.`Images` (`ImageID`) VALUES (12);
INSERT INTO `Equaliser`.`Images` (`ImageID`) VALUES (13);
INSERT INTO `Equaliser`.`Images` (`ImageID`) VALUES (14);
INSERT INTO `Equaliser`.`Images` (`ImageID`) VALUES (15);
INSERT INTO `Equaliser`.`Images` (`ImageID`) VALUES (16);
INSERT INTO `Equaliser`.`Images` (`ImageID`) VALUES (17);

COMMIT;


-- -----------------------------------------------------
-- Data for table `Equaliser`.`SecurityEventTypes`
-- -----------------------------------------------------
START TRANSACTION;
USE `Equaliser`;
INSERT INTO `Equaliser`.`SecurityEventTypes` (`SecurityEventTypeID`, `Name`) VALUES (1, 'user.login');
INSERT INTO `Equaliser`.`SecurityEventTypes` (`SecurityEventTypeID`, `Name`) VALUES (2, 'ephemeral_token.request');

COMMIT;

-- begin attached script 'Insert Append'
INSERT INTO Users (UserID, Username, CountryID, Forename, Surname, Email, AreaCode, SubscriberNumber, Token, Password, ImageID)
VALUES
(1, 'george', 1, 'George', 'Brighton', 'george@thebrightons.co.uk', '7528', '572988', UNHEX('f99b52eed9f365e51f20e49923039b6f510ce75756997bff9a8fdf16888c39cb'), '$2a$10$9puoa50eO8zBhp6pK03SPubFkRDQEfGnhAJ4UKrjxA1xJ9auQvHzC', 1),
(2, 'helen', 1, 'Helen', 'Crump', 'helen@helencrump.co.uk', '7401', '127718', UNHEX('a6c981a276d14d2fd91dbe07a86fd7ac520639298038bc828538f23feb96dd85'), '$2a$10$tZ.s1xVJiDOjbIn6yVnsuepIKbs/guBZPgog9aS0r.jUtGBHCvaqe', 2);

INSERT INTO SeriesImages (SeriesID, ImageID)
VALUES
(1, 3),
(2, 4),
(3, 5),
(4, 6),
(5, 7),
(6, 8),
(7, 9),
(8, 10),
(9, 11),
(10, 12),
(11, 13),
(12, 14),
(13, 15),
(14, 16),
(15, 17);

INSERT INTO ImageSizes (ImageID, Width, Height, Sha256)
VALUES
(1, 200, 200, UNHEX('3e81a7e64c8777dc3bf5169f604c247e80af1d41e2f36ce46f00da0c1d4f1518')),
(1, 500, 500, UNHEX('ddafc075c5fbc122bb1d7817bad5c8d2da8054a700845ca390beaf405155bac0')),
(2, 200, 200, UNHEX('12453d6207a22c6a508ac667b8e902701b316289b65425bf3cde0cefd5e9c2aa')),
(2, 500, 500, UNHEX('05613f0a1a526bc9215afef73bcb41a93dbaf9d0a9ef8b9549f72db235fcdf0d')),

(3, 1024, 512, UNHEX('04a575f54dfa349ac56f3c1c15846f3e912878de2061b8ee03723a11c697ec28')),
(3, 2048, 768, UNHEX('a4f08996edda0b3aec136371e8da067fa9a79b8bd50d1e69c19b531475e9de06')),
(4, 1024, 512, UNHEX('39304eef95dcc8f31fa3e50a3dbacfefa8ef4aa4f55122cb3f1a128a5aaa95c2')),
(4, 2048, 768, UNHEX('c02b82c27bc500bd8b37ba6f4cf16f495ed130a17e20f68e67f117ca8745cc51')),
(5, 1024, 512, UNHEX('dae0b87fc9c54d523b6496d40973865bdb14d4c4c74d39cdf68ae6db29be6984')),
(5, 2048, 768, UNHEX('bc298b3636385180734157e23671c01f70c1d79798594bf1d170851cce28c493')),
(6, 1024, 512, UNHEX('e56c054093f88b4b8dd2ce683bf37ee9ba104d2ecccc0e86556599c14c1cc214')),
(6, 2048, 768, UNHEX('9502044b8bc5414a5701ff2b0c9ce383dbef5c38e1fe3c827a6db10008ad85bd')),
(7, 1024, 512, UNHEX('1f1d9a708a00487058aede765b4e6824e39d53c3d3b9735bb50210a87ae305dd')),
(7, 2048, 768, UNHEX('47586665cddee45ecca500bb1d6c1013ff431b80f529c7eb8b1b29a33dc35a12')),
(8, 1024, 512, UNHEX('1124b890f61eb6ecc984f85eb97040254df0da1a02565b5dfc5e4d619b609669')),
(8, 2048, 768, UNHEX('db4b890dd0fd14a32e923457a4778c5cb64baeca19fab2da60920faa20653b01')),
(9, 1024, 512, UNHEX('46565b38fac54a2810d465cb7e187bf39c07b1cd8600efefc58adb3cc48ba9a3')),
(9, 2048, 768, UNHEX('c9ca6c6ec9233c404c148090cf1faaa34cd986648096c1dc07db658b03e41e27')),
(10, 1024, 512, UNHEX('dd75488f2f343b85591ce26373017726f42470e52580d2ceab60394836b2b2c2')),
(10, 2048, 768, UNHEX('3170a5238c70ff041be4baf3af1f14ee56a010bf52b6f2c739ed8007d208f5bb')),
(11, 1024, 512, UNHEX('7478d22a94549cad153de9f44dfb9502d6f7f373e019d040ed264f1e315a685e')),
(11, 2048, 768, UNHEX('992e7a7f3ab3e5692cbda3d456e9ba44c342cfd5df6d9f8874193e30d7abc8a7')),
(12, 1024, 512, UNHEX('d7e215b50bb34c617691a6af647d11659184839ae949f2fddbbca226c148b4ab')),
(12, 2048, 768, UNHEX('38a912b58e0843a8999335c75a735db6799dbb4337903ba86e9301e10f60641b')),
(13, 1024, 512, UNHEX('1b385266dc1da21998c1a6e4954402bf07c4efb1b76f500d7d27d0f14d830f3b')),
(13, 2048, 768, UNHEX('ad18d4942981353d95afafc0859fff42f124fee110f9f550362ff38415bab4be')),
(14, 1024, 512, UNHEX('3db8923b87ca3fd324c672a4dfc30af08cf2a233236f4169727fe263fa256126')),
(14, 2048, 768, UNHEX('c9b037492e12d427b3839261d699a758d5bf32a0e67fa278150645fc6a3639d3')),
(15, 1024, 512, UNHEX('086788ac07eb7c0ee8bccfb4ab300e34c6d4b43367dd4582655e29d332608cbd')),
(15, 2048, 768, UNHEX('a47ff9348273fb680096516a6b93a5a85618d392c829183a71f93e38d2a4a5a5')),
(16, 1024, 512, UNHEX('1bd58224b871c7f34cd2a741b1d98f093dcc12ac40c4dfa1774e49ee23815f0a')),
(16, 2048, 768, UNHEX('901c5f1a91b9d78b37298b26690724cb053f5e80dc22532eb8e97c28dd760be1')),
(17, 1024, 512, UNHEX('eaf65ed23f3644da406d728e270d0dc7eb0a863f2170ff8e799b5c7a2e4f351b')),
(17, 2048, 768, UNHEX('e35f54ae5055f61ed2d5cd151a594a886c2757ed62be3cd1c93d1b32c606f56a'));
-- end attached script 'Insert Append'
