CREATE TABLE expenses(
  id serial PRIMARY KEY,
  created_on date DEFAULT NOW() NOT NULL,
  amount numeric(6,2) NOT NULL CHECK(amount > 0.00),
  memo text NOT NULL
);
