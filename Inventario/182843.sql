CREATE TABLE item_stock (
    stock_id BIGSERIAL PRIMARY KEY,
    item_code VARCHAR(50) NOT NULL REFERENCES item(item_code),
    warehouse_id INT NOT NULL REFERENCES warehouse(warehouse_id),
    bin_id INT REFERENCES bin_location(bin_id),
    on_hand NUMERIC(19,6) NOT NULL DEFAULT 0 CHECK (on_hand >= 0),
    on_order NUMERIC(19,6) NOT NULL DEFAULT 0 CHECK (on_order >= 0),
    committed NUMERIC(19,6) NOT NULL DEFAULT 0 CHECK (committed >= 0),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX ux_item_stock
    ON item_stock (item_code, warehouse_id, COALESCE(bin_id, 0));

CREATE TABLE batch_stock (
    batch_id BIGINT NOT NULL REFERENCES batch(batch_id),
    warehouse_id INT NOT NULL REFERENCES warehouse(warehouse_id),
    qty NUMERIC(19,6) NOT NULL DEFAULT 0 CHECK (qty >= 0),
    PRIMARY KEY (batch_id, warehouse_id)
);

CREATE TABLE business_partner (
    partner_code VARCHAR(30) PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    is_customer BOOLEAN NOT NULL DEFAULT FALSE,
    is_supplier BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE purchase_order (
    po_id BIGSERIAL PRIMARY KEY,
    supplier_code VARCHAR(30) NOT NULL REFERENCES business_partner(partner_code),
    doc_date DATE NOT NULL DEFAULT CURRENT_DATE,
    status order_status NOT NULL DEFAULT 'ABIERTA'
);

CREATE TABLE purchase_order_line (
    po_id BIGINT NOT NULL REFERENCES purchase_order(po_id),
    line_no INT NOT NULL,
    item_code VARCHAR(50) NOT NULL REFERENCES item(item_code),
    warehouse_id INT NOT NULL REFERENCES warehouse(warehouse_id),
    qty NUMERIC(19,6) NOT NULL CHECK (qty > 0),
    qty_received NUMERIC(19,6) NOT NULL DEFAULT 0,
    unit_price NUMERIC(19,6) NOT NULL DEFAULT 0,
    qty_pending NUMERIC(19,6) GENERATED ALWAYS AS (qty - qty_received) STORED,
    PRIMARY KEY (po_id, line_no),
    CHECK (qty_received >= 0 AND qty_received <= qty)
);

CREATE TABLE sales_order (
    so_id BIGSERIAL PRIMARY KEY,
    customer_code VARCHAR(30) NOT NULL REFERENCES business_partner(partner_code),
    price_list_id INT,
    doc_date DATE NOT NULL DEFAULT CURRENT_DATE,
    status order_status NOT NULL DEFAULT 'ABIERTA'
);

CREATE TABLE sales_order_line (
    so_id BIGINT NOT NULL REFERENCES sales_order(so_id),
    line_no INT NOT NULL,
    item_code VARCHAR(50) NOT NULL REFERENCES item(item_code),
    warehouse_id INT NOT NULL REFERENCES warehouse(warehouse_id),
    qty NUMERIC(19,6) NOT NULL CHECK (qty > 0),
    qty_delivered NUMERIC(19,6) NOT NULL DEFAULT 0,
    unit_price NUMERIC(19,6) NOT NULL DEFAULT 0,
    qty_pending NUMERIC(19,6) GENERATED ALWAYS AS (qty - qty_delivered) STORED,
    PRIMARY KEY (so_id, line_no),
    CHECK (qty_delivered >= 0 AND qty_delivered <= qty)
);
