-- Library Management System Database



-- Creating a DATABASE library_management;
-- USE library_management;

-- Library Branches Table
CREATE TABLE library_branches (
    branch_id INT AUTO_INCREMENT,
    branch_name VARCHAR(100) NOT NULL,
    address VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(50) NOT NULL,
    zip_code VARCHAR(20) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100),
    opening_hours VARCHAR(255),
    PRIMARY KEY (branch_id),
    UNIQUE (branch_name)
);

-- Staff Table
CREATE TABLE staff (
    staff_id INT AUTO_INCREMENT,
    branch_id INT NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    position VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    hire_date DATE NOT NULL,
    salary DECIMAL(10,2),
    PRIMARY KEY (staff_id),
    UNIQUE (email),
    FOREIGN KEY (branch_id) REFERENCES library_branches(branch_id) ON DELETE RESTRICT
);

-- Books Table (main book information)
CREATE TABLE books (
    book_id INT AUTO_INCREMENT,
    isbn VARCHAR(20) NOT NULL,
    title VARCHAR(255) NOT NULL,
    aurthur VARCHAR(20) NOT NULL,
    aurthur_id INT,
    publication_year INT,
    publisher VARCHAR(100),
    language VARCHAR(50) DEFAULT 'English',
    page_count INT,
    description TEXT,
    date_added DATE NOT NULL DEFAULT (CURRENT_DATE),
    PRIMARY KEY (book_id),
    FOREIGN KEY (aurthur_id) REFERENCES book_aurthurs(aurthur_id),
    UNIQUE (isbn)
);

-- Authors Table
CREATE TABLE authors (
    author_id INT AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_year INT,
    death_year INT,
    biography TEXT,
    PRIMARY KEY (author_id)
);

-- Genres Table
CREATE TABLE genres (
    genre_id INT AUTO_INCREMENT,
    genre_name VARCHAR(50) NOT NULL,
    description TEXT,
    PRIMARY KEY (genre_id),
    UNIQUE (genre_name)
);

-- Members Table
CREATE TABLE members (
    member_id INT AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL, 
    date_of_birth DATE NOT NULL,
    address VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(50) NOT NULL,
    zip_code VARCHAR(20) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL,
    join_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    expiry_date DATE NOT NULL,
    membership_status ENUM('Active', 'Expired', 'Suspended') DEFAULT 'Active',
    PRIMARY KEY (member_id),
    UNIQUE (email)
);

-- Book-Authors Relationship (Many-to-Many)
CREATE TABLE book_authors (
    book_id INT,
    author_id INT,
    role ENUM('Primary', 'Co-author', 'Editor', 'Translator') DEFAULT 'Primary',
    PRIMARY KEY (book_id, author_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE RESTRICT
);

-- Book-Genres Relationship (Many-to-Many)
CREATE TABLE book_genres (
    book_id INT,
    genre_id INT,
    PRIMARY KEY (book_id, genre_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES genres(genre_id) ON DELETE RESTRICT
);

-- Book Copies Table (physical instances of books)
CREATE TABLE book_copies (
    copy_id INT AUTO_INCREMENT,
    book_id INT NOT NULL,
    branch_id INT NOT NULL,
    copy_number VARCHAR(20) NOT NULL,
    acquisition_date DATE NOT NULL,
    price DECIMAL(10,2),
    status ENUM('Available', 'Loaned', 'Reserved', 'Lost', 'Under Repair') DEFAULT 'Available',
    condition ENUM('New', 'Good', 'Fair', 'Poor') DEFAULT 'Good',
    location_code VARCHAR(50),
    PRIMARY KEY (copy_id),
    UNIQUE (book_id, branch_id, copy_number),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE RESTRICT,
    FOREIGN KEY (branch_id) REFERENCES library_branches(branch_id) ON DELETE RESTRICT
);

-- Loans Table
CREATE TABLE loans (
    loan_id INT AUTO_INCREMENT,
    copy_id INT NOT NULL,
    member_id INT NOT NULL,
    staff_id_checkout INT NOT NULL,
    staff_id_return INT,
    checkout_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    due_date DATE NOT NULL,
    return_date DATETIME,
    renewal_count INT DEFAULT 0,
    status ENUM('Active', 'Returned', 'Overdue', 'Lost') DEFAULT 'Active',
    PRIMARY KEY (loan_id),
    FOREIGN KEY (copy_id) REFERENCES book_copies(copy_id) ON DELETE RESTRICT,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE RESTRICT,
    FOREIGN KEY (staff_id_checkout) REFERENCES staff(staff_id) ON DELETE RESTRICT,
    FOREIGN KEY (staff_id_return) REFERENCES staff(staff_id) ON DELETE RESTRICT,
    CHECK (due_date > checkout_date),
    CHECK (renewal_count >= 0 AND renewal_count <= 3)
);

-- Reservations Table
CREATE TABLE reservations (
    reservation_id INT AUTO_INCREMENT,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    branch_id INT NOT NULL,
    reservation_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expiry_date DATE NOT NULL,
    status ENUM('Pending', 'Fulfilled', 'Cancelled', 'Expired') DEFAULT 'Pending',
    notification_sent BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (reservation_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE RESTRICT,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    FOREIGN KEY (branch_id) REFERENCES library_branches(branch_id) ON DELETE RESTRICT,
    CHECK (expiry_date > reservation_date)
);

-- Fines Table
CREATE TABLE fines (
    fine_id INT AUTO_INCREMENT,
    loan_id INT NOT NULL,
    member_id INT NOT NULL,
    fine_amount DECIMAL(10,2) NOT NULL,
    fine_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    reason ENUM('Overdue', 'Damaged', 'Lost') NOT NULL,
    status ENUM('Pending', 'Paid', 'Waived') DEFAULT 'Pending',
    PRIMARY KEY (fine_id),
    FOREIGN KEY (loan_id) REFERENCES loans(loan_id) ON DELETE RESTRICT,
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE RESTRICT,
    CHECK (fine_amount > 0)
);

-- Fine Payments Table
CREATE TABLE fine_payments (
    payment_id INT AUTO_INCREMENT,
    fine_id INT NOT NULL,
    payment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_amount DECIMAL(10,2) NOT NULL,
    payment_method ENUM('Cash', 'Credit Card', 'Debit Card', 'Online') NOT NULL,
    staff_id INT NOT NULL,
    receipt_number VARCHAR(50),
    PRIMARY KEY (payment_id),
    FOREIGN KEY (fine_id) REFERENCES fines(fine_id) ON DELETE RESTRICT,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON DELETE RESTRICT,
    CHECK (payment_amount > 0)
);

--indexes for performance optimization
CREATE INDEX idx_books_title ON books(title);
CREATE INDEX idx_members_name ON members(last_name, first_name);
CREATE INDEX idx_loans_dates ON loans(checkout_date, due_date, return_date);
CREATE INDEX idx_book_copies_status ON book_copies(status);
CREATE INDEX idx_fines_status ON fines(status);