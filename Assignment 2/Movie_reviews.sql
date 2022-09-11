/* My first attempt using SQL to create a table in a schema/database for movie reviews! */

create table `Results` (
	`Instance` INT NOT NULL AUTO_INCREMENT,
	`Name` varchar(15) NOT NULL,
    `Movie` varchar(40) NOT NULL,
    `Score` int DEFAULT NULL,
    Primary Key (`Instance`)
);

/* Did it work? */
describe Results;

/* Input data. Note columns explicitly so autoID generation works. */
insert into Results (`Name`, `Movie`, `Score`) values ('Jacqueline', 'Bullet Train', '3'), ('Jacqueline', 'Nope', null), ('Jacqueline', 'Top Gun: Maverick', '5'), ('Jacqueline', 'Everything Everywhere All at Once', '4'), ('Jacqueline', 'Elvis', '5'), ('Jacqueline', 'The Northman', '2'),
	('Jeff', 'Bullet Train', '2'), ('Jeff', 'Nope', '4'), ('Jeff', 'Top Gun: Maverick', null), ('Jeff', 'Everything Everywhere All at Once', '5'), ('Jeff', 'Elvis', '2'), ('Jeff', 'The Northman', null),
    ('Chris', 'Bullet Train', '4'), ('Chris', 'Nope', '5'), ('Chris', 'Top Gun: Maverick', '5'), ('Chris', 'Everything Everywhere All at Once', null), ('Chris', 'Elvis', '3'), ('Chris', 'The Northman', '4'),
	('Mandy', 'Bullet Train', null), ('Mandy', 'Nope', null), ('Mandy', 'Top Gun: Maverick', null), ('Mandy', 'Everything Everywhere All at Once', '1'), ('Mandy', 'Elvis', null), ('Mandy', 'The Northman', null),
    ('Savita', 'Bullet Train', '1'), ('Savita', 'Nope', '2'), ('Savita', 'Top Gun: Maverick', '2'), ('Savita', 'Everything Everywhere All at Once', '3'), ('Savita', 'Elvis', '2'), ('Savita', 'The Northman', '2'),
    ('Mauricio', 'Bullet Train', '5'), ('Mauricio', 'Nope', '1'), ('Mauricio', 'Top Gun: Maverick', '3'), ('Mauricio', 'Everything Everywhere All at Once', '2'), ('Mauricio', 'Elvis', '4'), ('Maurcio', 'The Northman', '3');

/* Check the data */
select count(*) from Results;
select * from Results;

/* Create a login/unique access to hide MySQL global password */
CREATE USER 'ACatlin' IDENTIFIED BY 'BenAssignment2';
GRANT SELECT, SHOW VIEW ON Results TO 'ACatlin';
SHOW GRANTS FOR ACatlin;