CREATE TABLE account (

  uname varchar(255) NOT NULL,
  pword varchar(255)NOT NULL,
  email varchar(255)NOT NULL,
  pId int NOT NULL,
  active datetime2(7)NOT NULL,
  cryptoMined bigint,
  isBanned bit NOT NULL
) 
