# Introduction to SQL and Postgres Cheatsheet

## shell commands
|Command|Function|
|---|---|
|`psql`|Interact with Postgres|
| ... `-d $name`|Connect to a database|
|`createdb $name`|Create a database|
|`dropdb $name`|Destroy a database|
|`pg_dump`|Utility for backing up and restoring|

## psql commands
### General
|Command|Function|
|---|---|
|`\?`|List psql commands|
|`\h`|List help topics|
|... `$topic`|View help for a specific topic|
|`\l`|List databases|
|`\c $name`|Connect to a database|
|`\q`|Quit|

### In a Database
|Command|Function|
|---|---|
|`\d`|Describe relations|
|... `$relation`| Describe a specific relation, e.g. a table schema|
|`\dt`|List tables in the database|

## SQL commands
### Table/schema operations (DDL)
|Command|Function|
|---|---|
|`CREATE TABLE`|Create a table|
|`ALTER TABLE $table`|Make a change to a table schema|
|... `RENAME TO $name`|Rename a table|
|... `ADD COLUMN $name [$options]`|Add a column|
|... `RENAME COLUMN $name TO $new_name`|Rename a column|
|... `ALTER COLUMN $name $attribute`|Change a column|
|... `DROP COLUMN $name`|Destroy a column|
|`DROP TABLE $name`|Destroy a table|
|`ADD CHECK $(condition)`|Add conditional expression performed on data|

```sql
CREATE TABLE all_orders (
    id serial UNIQUE NOT NULL,
    customer_name char(25) NOT NULL,
    burger varchar(12),
    side text,
    drink text,
    registered boolean DEFAULT TRUE
);

/*
one to one: User has one address
*/

CREATE TABLE addresses (
  user_id int, -- Both a primary and foreign key
  street varchar(30) NOT NULL,
  city varchar(30) NOT NULL,
  state varchar(30) NOT NULL,
  PRIMARY KEY (user_id),
  FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
);

CREATE TABLE books (
  id serial,
  title varchar(100) NOT NULL,
  author varchar(100) NOT NULL,
  published_date timestamp NOT NULL,
  isbn char(12),
  PRIMARY KEY (id),
  UNIQUE (isbn)
);

/*
 one to many: Book has many reviews
*/

CREATE TABLE reviews (
  id serial,
  book_id integer NOT NULL,
  reviewer_name varchar(255),
  content varchar(255),
  rating integer,
  published_date timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE
);

/*
many to many: user can checkout many books, books can have been checked out many times:
*/

CREATE TABLE checkouts (
  id serial,
  user_id int NOT NULL,
  book_id int NOT NULL,
  checkout_date timestamp,
  return_date timestamp,
  PRIMARY KEY (id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE
);

ALTER TABLE all_orders RENAME TO orders;
ALTER TABLE orders ALTER COLUMN side SET DEFAULT 'Fries';
ALTER TABLE users ADD CHECK (full_name <> '');
ALTER TABLE users ADD PRIMARY KEY (id);

ALTER TABLE films ADD CONSTRAINT title_unique UNIQUE (title);
ALTER TABLE films DROP CONSTRAINT title_unique;

ALTER TABLE films ADD CONSTRAINT title_length CHECK (length(title) >= 1);
ALTER TABLE films ADD CONSTRAINT year_range CHECK (year BETWEEN 1900 AND 2100);
```

### Data operations (DML)
|Command|Function|
|---|---|
|`INSERT INTO $table` ...|Add data|
|`SELECT $query`|Select data to operate on|
|... `FROM $table`|Narrow selection to a particular table|
|... `WHERE $criteria`|Narrow selection by attributes|
|... <code>ORDER BY $field [ASC&#124;DESC]</code>|Order the returned data|
|`UPDATE $table SET` ...|Change data|
|... `WHERE $criteria`|Narrow update to specific rows|
|`DELETE`|Delete data|
|... `FROM $table`|Narrow deletion to a particular table|
|... `WHERE $criteria`|Narrow deletion by attributes|

```sql
INSERT INTO users (full_name, enabled)
VALUES ('John Smith', false);

INSERT INTO users (full_name)
VALUES ('Jane Smith'), ('Harry Potter'), ('Bro Montana');

SELECT full_name, enabled FROM users
WHERE id < 2 ORDER BY full_name DESC, enabled DESC, other_column ASC;

...WHERE column IS NOT NULL AND column_two = 'true';
...WHERE details LIKE '%string';
...WHERE details SIMILAR TO /regexp/;

...LIMIT 5 OFFSET 5;

SELECT DISTINCT username FROM users;
SELECT count(DISTINCT username) FROM users;

UPDATE users SET enabled = 'false'
WHERE id = 5 OR full_name = 'Harry Potter';

DELETE FROM users
WHERE full_name = 'Jane Smith' AND id > 3;
```

### Functions
|Function|Example|Description|
|---|---|---|
|`length`|`SELECT length(full_name)...`|return length of column value|
|`trim`|`SELECT trim(leading ' ' from full_name) FROM users;`|remove leading spaces from any values in column|
|`date_part`|`SELECT full_name, date_part('year', last_login)...`|view a table that only contains part of timestamp we specify|
|`age`|`...ORDER BY age(last_login)`|when passed single timestamp, calculates time elapsed b/w that & current time|
|`count`|...|return number of values in column passed in|
|`min`|...|return lowest value in column for all rows being selected|
|`avg`|...|arithmetic average of numeric type values for selected rows|

```sql
GIVE EXAMPLES HERE

```

### Grouping
```sql
SELECT enabled, count(id) FROM users
GROUP BY enabled;
```

When using columns specified in an aggregate function, those columns must also appear in the `GROUP BY` clause. 

### Joins
|Command|Function|
|---|---|
|`SELECT $columns FROM $table`...|Select columns to display after joining tables. `$columns` can be in the format `$table.column` or `$other_table.column`|
|... `INNER JOIN $other_table ON $condition`|Return data which corresponds to an entry in both tables|
|... `LEFT JOIN $other_table ON $condition`|Return all rows in `$table`. For those that lack corresponding data in `$other_table`, leave the column from `$other_table` `null`|
|... `RIGHT JOIN $other_table ON $condition`| Return all rows in `$other_table`. For those that lack corresponding data in `$table`, leave `$table`'s columns `null`|
|... `CROSS JOIN $other_table`|Return all the combinations of rows from two tables|

```sql
SELECT colors.color, shapes.shape
FROM colors JOIN shapes /* same as INNER JOIN */
ON color.id = shapes.color_id;

SELECT users.*, addresses.*
FROM users LEFT JOIN addresses  /* same as LEFT OUTER JOIN */
ON (users.id = addresses.user_id);

SELECT reviews.book_id, reviews.content, reviews.rating,
reviews.published_date, books.id, books.title, books.autor
FROM reviews RIGHT JOIN books
ON (reviews.book_id = books.id);

SELECT * FROM users
CROSS JOIN addresses;

SELECT users.full_name, books.title, checkouts.checkout_date
FROM users
INNER JOIN checkouts ON (users.id = checkouts.user_id)
INNER JOIN books AS b ON (books.id = checkouts.book_id);

/* using table & column Aliasing */

SELECT u.full_name, b.title, c.checkout_date
FROM users AS u
INNER JOIN checkouts AS c ON (u.id = c.user_id)
INNER JOIN books AS b ON (b.id = c.book_id);

SELECT count(id) AS "Number of Books Checked Out"
FROM checkouts;

/* subqueries */
SELECT u.full_name FROM users u
WHERE u.id NOT IN (SELECT c.user_id FROM checkouts c);

/* same as */
SELECT u.full_name FROM users u
LEFT JOIN checkouts c ON (u.id = c.user_id)
WHERE c.user_id IS NULL;

SELECT directors.name, count(fd.director_id) AS films
FROM directors
    INNER JOIN films_directors fd ON directors.id = fd.director_id
GROUP BY directors.name
ORDER BY films DESC, directors.name ASC;
```


