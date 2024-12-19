-- Viewer Role
CREATE ROLE viewer WITH LOGIN PASSWORD 'viewer_password';
GRANT CONNECT ON DATABASE "IT-108-Finals" TO viewer;

-- Grant SELECT permission on specific tables
GRANT SELECT 
    ON public.roles, 
       public.authors, 
       public.books, 
       public.copies, 
       public.users, 
       public.status 
    TO viewer;

GRANT SELECT 
    ON view_borrowed_books,
	library_summary,
	view_books
    TO viewer;

GRANT INSERT, UPDATE, SELECT 
    ON borrowed_books
	TO viewer;


GRANT INSERT 
    ON users_logs 
    TO viewer;

GRANT USAGE, UPDATE ON SEQUENCE 
	public.borrowed_books_id_seq,
	public.users_logs_id_seq
TO viewer;

GRANT EXECUTE ON FUNCTION 
	public.get_borrowed_books_by_user,
	public.SearchBooksByTitle,
	public.insert_borrowed_book
TO viewer;





-- Editor Role	
CREATE ROLE editor WITH LOGIN PASSWORD 'editor_password';
GRANT CONNECT ON DATABASE "IT-108-Finals" TO editor;

-- Grant SELECT, INSERT, and UPDATE permissions on specific tables
GRANT SELECT ON 
    public.roles, 
    public.authors, 
    public.books, 
    public.copies, 
    public.users, 
    public.borrowed_books, 
    public.status 
TO editor;

GRANT INSERT, UPDATE, DELETE ON 
    public.authors, 
    public.books, 
    public.copies, 
    public.borrowed_books 
TO editor;

GRANT SELECT ON 
    view_books, 
	view_borrowed_books,
	view_borrowed_books_status_1,
	library_summary
TO editor;

GRANT UPDATE ON 
    public.status 
TO editor;

GRANT INSERT ON 
    users_logs 
TO editor;

GRANT USAGE, UPDATE ON SEQUENCE 
    public.authors_id_seq, 
    public.books_id_seq, 
    public.copies_id_seq,
	public.users_logs_id_seq
TO editor;



-- Admin Role
CREATE ROLE admin WITH LOGIN PASSWORD 'admin_password';
GRANT CONNECT ON DATABASE "IT-108-Finals" TO admin;

-- Grant all permissions, including GRANT OPTION
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO admin;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO admin;

ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO admin;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT EXECUTE ON FUNCTIONS TO admin;


--Triggers on all tables if changes are made
CREATE OR REPLACE TRIGGER book_changes
AFTER INSERT OR UPDATE OR DELETE ON books
FOR EACH ROW 
EXECUTE FUNCTION log_user_changes();

CREATE OR REPLACE TRIGGER copies_changes
AFTER INSERT OR UPDATE OR DELETE ON copies 
FOR EACH ROW 
EXECUTE FUNCTION log_user_changes();

CREATE OR REPLACE TRIGGER borrowed_book_changes
AFTER INSERT OR UPDATE OR DELETE ON borrowed_books 
FOR EACH ROW 
EXECUTE FUNCTION log_user_changes();

CREATE OR REPLACE TRIGGER authors_changes
AFTER INSERT OR UPDATE OR DELETE ON authors 
FOR EACH ROW 	
EXECUTE FUNCTION log_user_changes();


CREATE OR REPLACE TRIGGER users_changes
AFTER INSERT OR UPDATE OR DELETE ON users 
FOR EACH ROW 
EXECUTE FUNCTION log_user_changes();


--Functions for logging actions
			CREATE OR REPLACE FUNCTION log_user_changes()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
      INSERT INTO users_logs (user_id, table_name, action, created_at, user_type)
      VALUES (COALESCE(current_setting('myapp.user_id', true)::integer, 0), TG_TABLE_NAME, TG_OP, NOW(), CURRENT_USER);
  ELSE
      INSERT INTO users_logs (user_id, table_name, action, created_at, user_type)
      VALUES (COALESCE(current_setting('myapp.user_id', true)::integer, 0), TG_TABLE_NAME, TG_OP, NOW(), CURRENT_USER);
  END IF;
  RETURN NEW;  
END;
$$ LANGUAGE plpgsql;

select*from view_books


--functions for the search query
select SearchBooksByTitle('The')
		CREATE OR REPLACE FUNCTION SearchBooksByTitle(TitleSearch VARCHAR)
		RETURNS TABLE (
			ID BIGINT,          
			TITLE VARCHAR,
			CATEGORY VARCHAR,
			GENRE VARCHAR,
			AUTHOR_NAME VARCHAR,
			AUTHOR_COUNTRY VARCHAR,
			YEAR_PUBLISHED DATE,   
			NUM_COPIES BIGINT    
		) AS $$
		BEGIN
			RETURN QUERY
			SELECT 
				b.ID,                               
				b.TITLE,
				b.CATEGORY,
				b.GENRE,
				a.NAME AS AUTHOR_NAME,
				a.COUNTRY AS AUTHOR_COUNTRY,
				b.YEAR_PUBLISHED,                   
				COALESCE(copies.count, 0) AS NUM_COPIES
			FROM 
				BOOKS b
			JOIN 
				AUTHORS a ON a.ID = b.AUTHOR_ID
			LEFT JOIN 
				(
					SELECT 
						BOOK_ID,  
						COUNT(*) AS count
					FROM 
						COPIES 
					GROUP BY 
						BOOK_ID
				) copies ON b.ID = copies.BOOK_ID
			WHERE 
				b.TITLE ILIKE '%' || TitleSearch || '%'; 
		END;
		$$ LANGUAGE plpgsql;


--Genereal views of totality
CREATE OR REPLACE VIEW library_summary AS
SELECT
    (SELECT COUNT(*) FROM users WHERE role_id = 1) AS total_users_role_1,
    (SELECT COUNT(*) FROM users WHERE role_id = 2) AS total_librarians_role_2,
    (SELECT COUNT(*) FROM users WHERE role_id = 3) AS total_admins_role_3,
	(SELECT COUNT(*) FROM users) AS total_users,
    (SELECT COUNT(*) FROM books) AS total_books,
    (SELECT COUNT(*) FROM borrowed_books WHERE status_id NOT IN (3, 4)) AS total_borrowed_books,
	total_books_borrowed_today() AS books_borrowed_today;
	
SELECT * FROM library_summary;




select*from pg_indexes








--functions utilized in users interface
--multiple functions are stored here
--thiss is for viewing all the available books

CREATE OR REPLACE VIEW view_books AS 
SELECT 
    b.id,
    b.title,
    b.category,
    b.genre,
    a.name AS author_name,
    a.country AS author_country,
    b.year_published,
    COALESCE(copies.available_count, 0) AS num_copies
FROM books b
JOIN authors a ON a.id = b.author_id
LEFT JOIN (
    SELECT
	c.id,
		bb.status_id,
		bb.copy_id,
        c.book_id,
        COUNT(DISTINCT c.id) AS available_count -- Count only unique copies
    FROM copies c
    LEFT JOIN borrowed_books bb ON c.id = bb.copy_id
    WHERE 
        LOWER(c.status) = 'available'  -- Only consider copies marked as available
        AND (
            bb.status_id IS NULL       -- Not borrowed yet
            OR bb.status_id = 3        -- Returned
            OR bb.status_id = 4        -- Denied
        )
    GROUP BY c.id, c.book_id,bb.status_id,bb.copy_id
) copies ON b.id = copies.book_id;
	
	
	


delete from borrowed_books
select*from view_books
select*from view_borrowed_books
select*from copies
--this is for viewing the borrowed books logs
		CREATE OR REPLACE VIEW view_borrowed_books AS
		SELECT 
			bb.id AS borrowed_id,
			bb.users_id,
			u.name AS user_name,
			c.id,
			b.title AS book_title,
			bb.date_borrowed,
			bb.return_date,
			s.current_status
		FROM 
			users u
		JOIN 
			borrowed_books bb ON u.id = bb.users_id
		JOIN 
			copies c ON bb.copy_id = c.id
		JOIN 
			books b ON c.book_id = b.id
		JOIN 
			status s ON bb.status_id = s.id;
			
--view specific books borrowed by users
		CREATE OR REPLACE FUNCTION get_borrowed_books_by_user(input_user_id BIGINT)
		RETURNS TABLE (
			borrowed_book_id BIGINT,
			user_id BIGINT,
			user_name VARCHAR,
			copy_id BIGINT,
			book_title VARCHAR,
			date_borrowed DATE,
			return_date DATE,
			current_status VARCHAR
		)
		AS $$
		BEGIN
			RETURN QUERY
			SELECT 
				bb.borrowed_id,
				bb.users_id,
				bb.user_name,
				bb.id,
				bb.book_title,
				bb.date_borrowed,
				bb.return_date,
				bb.current_status
			FROM view_borrowed_books bb
			WHERE bb.users_id = input_user_id;
		END;
		$$ LANGUAGE plpgsql;

--to insert books borrowed
select*from view_borrowed_books
select*from view_books
select*from users
SELECT insert_borrowed_book(10,2)
CREATE OR REPLACE FUNCTION insert_borrowed_book(
    p_users_id INTEGER,
    p_book_id INTEGER
) RETURNS VOID AS $$
DECLARE
    v_copy_id INTEGER;
    v_date_borrowed DATE := CURRENT_DATE;
    available_copies_count INTEGER;
BEGIN
    -- Check if the user has already borrowed this book with a non-returned or non-denied status
    IF EXISTS (
        SELECT 1
        FROM borrowed_books bb
        JOIN copies c ON bb.copy_id = c.id
        WHERE bb.users_id = p_users_id
          AND c.book_id = p_book_id
          AND bb.status_id NOT IN (3, 4) -- Exclude returned (3) and denied (4)
    ) THEN
        RAISE EXCEPTION 'User has already borrowed this book: %', p_book_id;
    END IF;

    -- Count the available copies for the given book ID with 'Available' status
    SELECT COUNT(*)
    INTO available_copies_count
    FROM copies c
    LEFT JOIN borrowed_books bb ON c.id = bb.copy_id
    WHERE c.book_id = p_book_id
      AND c.status = 'Available'
      AND (bb.status_id IS NULL OR bb.status_id IN (3, 4)); -- Available if no active borrow or returned/denied

    -- If no copies are available, raise an error
    IF available_copies_count < 1 THEN
        RAISE EXCEPTION 'No available copies for the specified book ID: %', p_book_id;
    END IF;

    -- Find an available copy for the given book ID
    SELECT c.id
    INTO v_copy_id
    FROM copies c
    LEFT JOIN borrowed_books bb ON c.id = bb.copy_id
    WHERE c.book_id = p_book_id
      AND c.status = 'Available'
      AND (bb.status_id IS NULL OR bb.status_id IN (3, 4)) -- Available if no active borrow or returned/denied
    LIMIT 1;

    -- Insert into borrowed_books using the detected copy_id
    INSERT INTO borrowed_books (
        users_id,
        copy_id,
        date_borrowed,
        status_id, -- Status ID is always set to 1 (pending)
        return_date,
        created_at,
        updated_at
    ) VALUES (
        p_users_id,
        v_copy_id,
        v_date_borrowed,
        1, -- Explicitly set status_id to 1 (pending)
        NULL, -- Default return_date to NULL
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    );

   
END;
$$ LANGUAGE plpgsql;






--functions utilized in librarian interface
--some of the functionalities that are needed here are already on user interface
--this is for viewing the the logs you are accepting
		CREATE OR REPLACE VIEW view_borrowed_books_status_1 AS
		SELECT 
			bb.id AS borrowed_id,
			bb.users_id,
			u.name AS user_name,
			c.id,
			b.title AS book_title,
			bb.date_borrowed,
			bb.return_date,
			s.current_status
		FROM 
			users u
		JOIN 
			borrowed_books bb ON u.id = bb.users_id
		JOIN 
			copies c ON bb.copy_id = c.id
		JOIN 
			books b ON c.book_id = b.id
		JOIN 
			status s ON bb.status_id = s.id
		WHERE bb.status_id = 1 OR bb.status_id = 2

--Function to Update books status to (accepted and returned)
		CREATE OR REPLACE FUNCTION update_borrowed_book_status(
			p_borrowed_book_id INT,
			p_new_status_id INT
		)
		RETURNS VOID AS $$
		BEGIN
			-- Validate the new status_id value
			IF p_new_status_id NOT IN (1, 2, 3, 4) THEN
				RAISE EXCEPTION 'Invalid status_id. Allowed values are 1, 2, or 3.';
			END IF;

			-- Handle different cases for p_new_status_id
			CASE p_new_status_id
				WHEN 1 THEN
					-- Logic for status_id = 1 (e.g., Borrowed)
					UPDATE BORROWED_BOOKS
					SET status_id = p_new_status_id,
						updated_at = CURRENT_TIMESTAMP,
						return_date = NULL -- Clear date_returned since it's borrowed
					WHERE id = p_borrowed_book_id;

				WHEN 2 THEN
					-- Logic for status_id = 2 (e.g., Reserved)
					UPDATE BORROWED_BOOKS
					SET status_id = p_new_status_id,
						updated_at = CURRENT_TIMESTAMP,
						return_date = NULL -- Clear date_returned since it's reserved
					WHERE id = p_borrowed_book_id;

				WHEN 3 THEN
					-- Logic for status_id = 3 (e.g., Returned)
					UPDATE BORROWED_BOOKS
					SET status_id = p_new_status_id,
						updated_at = CURRENT_TIMESTAMP,
						return_date = CURRENT_TIMESTAMP -- Set the return date
					WHERE id = p_borrowed_book_id;
					
				WHEN 4 THEN
					-- Logic for status_id = 4 (e.g., Returned)
					UPDATE BORROWED_BOOKS
					SET status_id = p_new_status_id,
						updated_at = CURRENT_TIMESTAMP,
						return_date = CURRENT_TIMESTAMP -- Set the return date
					WHERE id = p_borrowed_book_id;
			END CASE;
		END;
		$$ LANGUAGE plpgsql;

		
--delete functionality in librarian
		CREATE OR REPLACE FUNCTION delete_book_and_unused_authors(book_id INT) RETURNS VOID AS $$
		BEGIN
			-- Delete the book record
			DELETE FROM books WHERE id = book_id;

			-- Delete authors with no remaining books
			DELETE FROM authors 
			WHERE id NOT IN (SELECT DISTINCT author_id FROM books);
		END;
		$$ LANGUAGE plpgsql;

--update functionality on the books
select*from view_books
select update_book_and_copies(
    25,
    'the heck',
    'zzz',
    'zzzz',
    '2021-01-01',
    5 -- Replace with the correct number of copies
);
		CREATE OR REPLACE FUNCTION update_book_and_copies(
			input_book_id INT,
			new_title TEXT,
			new_category TEXT,
			new_genre TEXT,
			new_year_published DATE,
			new_number_of_copies INT
		) RETURNS VOID AS $$
		DECLARE
			current_copies_count INT;
		BEGIN
			-- Update the book's information
			UPDATE books
			SET title = new_title,
				category = new_category,
				genre = new_genre,
				year_published = new_year_published,
				updated_at = NOW()
			WHERE id = input_book_id;

			-- Get the current number of copies for the book
			SELECT COUNT(*) INTO current_copies_count 
			FROM copies 
			WHERE copies.book_id = input_book_id;

			-- Adjust the number of copies
			IF current_copies_count < new_number_of_copies THEN
				-- Add new copies
				INSERT INTO copies (book_id, date_encoded, status,created_at, updated_at)
				SELECT input_book_id, NOW(), 'Available', NOW(),NOW()
				FROM generate_series(1, new_number_of_copies - current_copies_count);
			ELSIF current_copies_count > new_number_of_copies THEN
				-- Remove extra copies
				DELETE FROM copies
				WHERE id IN (
					SELECT id
					FROM copies
					WHERE copies.book_id = input_book_id
					ORDER BY date_encoded DESC
					LIMIT (current_copies_count - new_number_of_copies)
				);

				-- Update updated_at for remaining copies
				UPDATE copies
				SET updated_at = NOW()
				WHERE book_id = input_book_id;
			END IF;
		END;
		$$ LANGUAGE plpgsql;


--adding a new book functionality
		select add_book_with_author_and_copy ('the heck','zzz','zzzz','2021-01-01','marc','ph')

		CREATE OR REPLACE FUNCTION add_book_with_author_and_copy(
			input_title TEXT,
			input_category TEXT,
			input_genre TEXT,
			input_year_published DATE,
			input_author_name TEXT,
			input_author_country TEXT
		) RETURNS TEXT AS $$
		DECLARE
			authors_id INT;
			book_id INT;
			existing_book_id INT;
		BEGIN
			-- Check if the author already exists
			SELECT id INTO authors_id
			FROM authors
			WHERE name = input_author_name AND country = input_author_country;

			-- If the author does not exist, insert the new author
			IF authors_id IS NULL THEN
				INSERT INTO authors (name, country, created_at, updated_at)
				VALUES (input_author_name, input_author_country, NOW(), NOW())
				RETURNING id INTO authors_id;
			END IF;

			-- Check if a book with the same title and author already exists
			SELECT id INTO existing_book_id
			FROM books
			WHERE title = input_title AND author_id = authors_id;

			-- If the book already exists, do not add it
			IF existing_book_id IS NOT NULL THEN
				RETURN 'Book already exists. No new book was added.';
			END IF;

			-- Insert the new book
			INSERT INTO books (title, category, genre, year_published, author_id, created_at, updated_at)
			VALUES (input_title, input_category, input_genre, input_year_published, authors_id, NOW(), NOW())
			RETURNING id INTO book_id;

			-- Automatically generate 1 copy for the new book
			INSERT INTO copies (book_id, date_encoded, status, created_at, updated_at)
			VALUES (book_id, NOW(), 'Available', NOW(), NOW());

			RETURN 'New book and its copy added successfully.';
		END;
		$$ LANGUAGE plpgsql;







--Functions utilized in admin interface

CREATE OR REPLACE FUNCTION total_books_borrowed_today()
RETURNS INTEGER AS $$
BEGIN
    RETURN (
        SELECT COUNT(*)
        FROM borrowed_books
        WHERE date_borrowed = CURRENT_DATE
    );
END;
$$ LANGUAGE plpgsql;

select total_books_borrowed_today()


CREATE MATERIALIZED VIEW user_activity_logs AS 
SELECT 
    ul.id AS log_id,          -- Log ID from users_logs
    ul.user_id AS users_id,   -- User ID from users_logs
    u.name AS username,       -- Username from users table
    ul.table_name,            -- Table name from users_logs
    ul.action,                -- Action from users_logs
    ul.created_at AS time,    -- Timestamp from users_logs
    ul.user_type AS role      -- Role from users_logs
FROM 
    users_logs ul
LEFT JOIN 
    users u ON ul.user_id = u.id; -- Match user_id in users_logs with id in users



delete from users_logs
select*from user_activity_logs
REFRESH MATERIALIZED VIEW user_activity_logs
ALTER MATERIALIZED VIEW user_activity_logs OWNER TO admin;










select*from view_books
select*from roles
select*from users
select*from users_logs
select*from authors
select*from books
select*from copies
select*from borrowed_books
select*from status
delete from authors
delete from books_logs
delete from copies
delete from users_logs



INSERT INTO roles (id, user_type, created_at, updated_at) VALUES
(3,'admin', now(),null),
(2,'librarian', now(), null),
(1,'user', now(), null);
INSERT INTO status (id, current_status, created_at, updated_at) VALUES
(4,'denied', now(),null),
(3,'returned', now(),null),
(2,'accepted', now(), null),
(1,'pending', now(), null);




--sample datas
select*from authors
INSERT INTO AUTHORS (NAME, COUNTRY, created_at, updated_at) VALUES
('Anne Frank', 'Netherlands', now(), now()),
('Charles Duhigg', 'United States', now(), now()),
('David McCullough', 'United States', now(), now()),
('Elizabeth Kolbert', 'United States', now(), now()),
('F. Scott Fitzgerald', 'United States', now(), now()),
('George Orwell', 'United Kingdom', now(), now()),
('Harper Lee', 'United States', now(), now()),
('Herman Melville', 'United States', now(), now()),
('J.D. Salinger', 'United States', now(), now()),
('J.K. Rowling', 'United Kingdom', now(), now()),
('J.R.R. Tolkien', 'United Kingdom', now(), now()),
('Jane Austen', 'United Kingdom', now(), now()),
('Jon Krakauer', 'United States', now(), now()),
('Mary Shelley', 'United Kingdom', now(), now()),
('Rebecca Skloot', 'United States', now(), now()),
('Siddhartha Mukherjee', 'India', now(), now()),
('Tara Westover', 'United States', now(), now()),
('Trevor Noah', 'South Africa', now(), now()),
('Yuval Noah Harari', 'Israel', now(), now());


select*from books
INSERT INTO BOOKS (TITLE, CATEGORY, GENRE, AUTHOR_ID, YEAR_PUBLISHED, created_at, updated_at) VALUES 
('To Kill a Mockingbird', 'Fiction', 'Southern Gothic', 7, '1960-01-01', NOW(), NOW()),
('1984', 'Fiction', 'Dystopian', 6, '1949-01-01', NOW(), NOW()),
('The Great Gatsby', 'Fiction', 'Tragedy', 5, '1925-01-01', NOW(), NOW()),
('Pride and Prejudice', 'Fiction', 'Romance', 12, '1813-01-01', NOW(), NOW()),
('The Catcher in the Rye', 'Fiction', 'Coming-of-Age', 9, '1951-01-01', NOW(), NOW()),
('The Lord of the Rings', 'Fiction', 'Fantasy', 11, '1954-01-01', NOW(), NOW()),
('Harry Potter and the Philosopher''s Stone', 'Fiction', 'Fantasy', 10, '1997-01-01', NOW(), NOW()),
('The Hobbit', 'Fiction', 'Fantasy', 11, '1937-01-01', NOW(), NOW()),
('Moby-Dick', 'Fiction', 'Adventure', 8, '1851-01-01', NOW(), NOW()),
('Frankenstein', 'Fiction', 'Gothic', 14, '1818-01-01', NOW(), NOW()),
('Sapiens: A Brief History of Humankind', 'Non-Fiction', 'Anthropology', 19, '2011-01-01', NOW(), NOW()),
('The Immortal Life of Henrietta Lacks', 'Non-Fiction', 'Biography', 15, '2010-01-01', NOW(), NOW()),
('The Diary of a Young Girl', 'Non-Fiction', 'Autobiography', 1, '1947-01-01', NOW(), NOW()),
('Into the Wild', 'Non-Fiction', 'Adventure', 13, '1996-01-01', NOW(), NOW()),
('The Sixth Extinction: An Unnatural History', 'Non-Fiction', 'Science', 4, '2014-01-01', NOW(), NOW()),
('Born a Crime: Stories from a South African Childhood', 'Non-Fiction', 'Autobiography', 18, '2016-01-01', NOW(), NOW()),
('Educated', 'Non-Fiction', 'Memoir', 17, '2018-01-01', NOW(), NOW()),
('The Wright Brothers', 'Non-Fiction', 'History', 8, '2015-01-01', NOW(), NOW()),
('The Emperor of All Maladies: A Biography of Cancer', 'Non-Fiction', 'Medicine', 16, '2010-01-01', NOW(), NOW()),
('The Power of Habit: Why We Do What We Do in Life and Business', 'Non-Fiction', 'Psychology', 2, '2012-01-01', NOW(), NOW());

select*from copies
INSERT INTO COPIES (BOOK_ID, DATE_ENCODED, STATUS, created_at, updated_at) VALUES
(1, '2000-12-27', 'Available', now(), now()),
(2, '2001-05-17', 'Available', now(), now()),
(2, '2001-08-16', 'Available', now(), now()),
(3, '2002-04-20', 'Available', now(), now()),
(3, '2003-04-14', 'Available', now(), now()),
(4, '2003-07-19', 'Available', now(), now()),
(4, '2005-04-09', 'Available', now(), now()),
(5, '2005-01-08', 'Available', now(), now()),
(6, '2006-05-15', 'Available', now(), now()),
(6, '2007-02-03', 'Available', now(), now()),
(7, '2007-06-19', 'Available', now(), now()),
(7, '2009-09-15', 'Available', now(), now()),
(8, '2010-05-02', 'Available', now(), now()),
(8, '2010-10-02', 'Available', now(), now()),
(9, '2010-12-22', 'Available', now(), now()),
(10, '2010-06-23', 'Available', now(), now()),
(10, '2011-04-20', 'Lost', now(), now()),
(10, '2012-07-16', 'Available', now(), now()),
(11, '2012-01-20', 'Available', now(), now()),
(11, '2012-02-15', 'Available', now(), now()),
(12, '2013-05-04', 'Available', now(), now()),
(12, '2013-07-05', 'Available', now(), now()),
(13, '2013-09-08', 'Available', now(), now()),
(13, '2014-04-08', 'Destroyed', now(), now()),
(13, '2014-10-12', 'Available', now(), now()),
(13, '2015-10-23', 'Lost', now(), now()),
(14, '2015-10-25', 'Available', now(), now()),
(15, '2016-04-24', 'Available', now(), now()),
(15, '2016-08-07', 'Available', now(), now()),
(16, '2016-07-11', 'Available', now(), now()),
(17, '2016-05-01', 'Available', now(), now()),
(17, '2016-10-30', 'Available', now(), now()),
(18, '2017-04-17', 'Available', now(), now()),
(18, '2017-08-21', 'Available', now(), now()),
(18, '2017-11-29', 'Available', now(), now()),
(19, '2018-09-25', 'Available', now(), now()),
(19, '2018-11-09', 'Available', now(), now()),
(20, '2019-02-08', 'Available', now(), now()),
(20, '2019-05-25', 'Destroyed', now(), now()),
(20, '2019-06-16', 'Lost', now(), now());
