# **Olympics History SQL Queries**

## **Project Overview**
This project involves querying an Olympic Games dataset stored in a relational database using PostgreSQL. 

### **The dataset contains two main tables:**

**OLYMPICS_HISTORY** – which stores detailed information about athletes and their performance in various Olympic Games.

**OLYMPICS_HISTORY_NOC_REGIONS** – which provides information about the National Olympic Committees (NOCs) and the corresponding regions.

The goal of this project is to perform a variety of analytical queries to gain insights into the Olympic Games, such as the number of games held, countries participating, sports played, medal counts, and identifying top athletes and nations.

The project includes 20 SQL queries, each designed to answer a specific question about the Olympics data.

## **Datasets Link:-** 
https://drive.google.com/drive/folders/1v4aQ21Spaa4gLZOU8NqEkD9f_Ijwup6d?usp=drive_link

## **Prerequisites**
**Before running the queries, ensure you have the following software installed:**

A relational database (e.g., PostgreSQL, MySQL) In my case it is PostgreSQL

SQL editor or command-line interface

**Optional**: Data import/export tool

## **Dataset Source**

### **The dataset consists of two tables:**

**OLYMPICS_HISTORY:** Stores information about the athletes, their participation, medals won, and more.

**OLYMPICS_HISTORY_NOC_REGIONS**: Maps National Olympic Committees (NOC) to their respective regions (countries).

The dataset can be imported into your SQL environment using the import/export functionality or directly from SQL files.

## **Database Schema**
### **Table 1: OLYMPICS_HISTORY**

______________________________________________
**Column Name** |	**Type**	  | **Description**  

______________________________________________
id\t	        | INT	    | Athlete ID (Primary key)

name	    | VARCHAR   |	Athlete name

sex	        | VARCHAR	| Athlete's gender (M/F)

age	        | VARCHAR	| Athlete's age

height	    | VARCHAR	| Athlete's height (cm)

weight	    | VARCHAR	| Athlete's weight (kg)

team	    | VARCHAR	| Athlete's team or country

noc	        | VARCHAR	| National Olympic Committee code (NOC)

games	    | VARCHAR	| Olympic games edition (e.g., 2016 Summer)

year	    | INT	    | Year of the Olympic games

season	    | VARCHAR	| Season (Summer/Winter)

city	    | VARCHAR	| Host city

sport	    | VARCHAR	| Sport played

event	    | VARCHAR	| Event within the sport

medal	    | VARCHAR	| Medal won (Gold/Silver/Bronze/None)

### **Table 2: OLYMPICS_HISTORY_NOC_REGIONS**

_____________________________________
**Column Name** |	**Type**	   | **Description**

_____________________________________
noc	        | VARCHAR	 | National Olympic Committee code (Primary key)

region	    | VARCHAR	 | Corresponding region or country

notes	    | VARCHAR	 | Additional notes on the NOC


## **Setup Instructions**

### **Step 1:** Create the Database and Tables

**Run the following SQL script to create the necessary tables:**

        DROP TABLE IF EXISTS OLYMPICS_HISTORY;
        
        CREATE TABLE IF NOT EXISTS OLYMPICS_HISTORY
        
        (
        
            id          INT,
            
            name        VARCHAR,
            
            sex         VARCHAR,
            
            age         VARCHAR,
            
            height      VARCHAR,
            
            weight      VARCHAR,
            
            team        VARCHAR,
            
            noc         VARCHAR,
            
            games       VARCHAR,
            
            year        INT,
            
            season      VARCHAR,
            
            city        VARCHAR,
            
            sport       VARCHAR,
            
            event       VARCHAR,
            
            Medal       VARCHAR
            
        );

        *DROP TABLE IF EXISTS OLYMPICS_HISTORY_NOC_REGIONS;*
        
        *CREATE TABLE IF NOT EXISTS OLYMPICS_HISTORY_NOC_REGIONS*
        
        (
        
            noc         VARCHAR,
            
            region      VARCHAR,
            
            notes       VARCHAR
            
        );

### **Step 2: Import the Data**

Use your database’s import/export feature to load data into the OLYMPICS_HISTORY and OLYMPICS_HISTORY_NOC_REGIONS tables. Ensure to properly handle escape characters when loading the data to avoid import issues.

### **Step 3: Run the Queries**
Each of the following queries provides insights into the Olympic data. You can run them one at a time to answer specific questions about the dataset.

## **Key Queries**

**1. How many Olympic Games have been held?**
   
        CREATE MATERIALIZED VIEW total_games AS
        
        SELECT COUNT(1) AS total_olympic_games
        
        FROM 
        
           (
           
              SELECT games FROM OLYMPICS_HISTORY GROUP BY games
              
           ) AS subquery;
        
        SELECT * FROM total_games;

**2. List down all Olympics games held so far.**

        SELECT 
        
            SUBSTRING(games, 1, POSITION(' ' IN games)) AS year, 
            
            SUBSTRING(games, POSITION(' ' IN games)) AS season, 
            
            city
            
        FROM OLYMPICS_HISTORY
        
        GROUP BY games, city
        
        ORDER BY year;

**3. Number of nations participating in each Olympics game.**

        CREATE MATERIALIZED VIEW total_no_of_countries_per_season AS
        
        SELECT 
        
            games, 
            
            COUNT(1) AS total_countries
            
        FROM 
        
        (
        
            SELECT games, region
            
            FROM OLYMPICS_HISTORY oh
            
            JOIN OLYMPICS_HISTORY_NOC_REGIONS ohn USING(noc)
            
            GROUP BY games, region
            
            ORDER BY games
            
            ) AS no_of_countries
            
        GROUP BY games;
        
        SELECT * FROM total_no_of_countries_per_season;

## **Running the Queries**

Once you have set up the database and imported the data, you can run the above queries to get insights into the Olympic Games data.

## **List of Queries**
**Query 1**: How many Olympic Games have been held?

**Query 2**: List all Olympic Games held so far.

**Query 3**: Number of nations participating in each Olympics game.

**Query 4:** Which year saw the highest and lowest number of countries participating?

**Query 5:** Which nation has participated in all Olympic Games?

**Query 6**: Sport played in all Summer Olympic Games.

**Query 7**: Sports played only once in the Olympics.

**Query 8**: Total number of sports played in each Olympic Games.

**Query 9**: Oldest athlete to win a gold medal.

**Query 10**: Ratio of male to female athletes.

**Query 11:** Top 5 athletes with the most gold medals.

**Query 12**: Top 5 athletes with the most total medals.

**Query 13**: Top 5 most successful countries (by medals).

**Query 14**: Total gold, silver, and bronze medals by country.

**Query 15**: Total gold, silver, and bronze medals by country for each Olympic Games.

**Query 16**: Country with the most gold, silver, and bronze medals in each Olympics.

**Query 17**: Countries that won the most medals in each Olympics.

**Query 18**: Countries that have never won gold but have won silver/bronze.

**Query 19**: Sports in which India has won the highest number of medals.

**Query 20**: Breakdown of Olympic Games where India won medals in Hockey.


## **Conclusion**
This project analyzes historical Olympic data to derive meaningful insights into the athletes, countries, and sports played in various editions of the Olympic Games. The SQL queries provide useful information ranging from medal counts to participation statistics and athlete-specific achievements.
