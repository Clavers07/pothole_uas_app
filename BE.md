# `app.js` Migration Documentation

This document outlines the changes that were made to migrate the backend application from the previous waste management system (`sampah`) to the new pothole reporting system (`reports`) in `app.js`.

## Overview of Changes

The primary goal of the refactor was to adapt the existing backend structure to support reporting potholes ("jalan berlubang") instead of waste. The core functionalities such as user authentication (including face login) and image upload via `multer` were retained, but the main domain entities and endpoints were completely swapped out.

### 1. Environment and Configuration
- **JWT Secret Key:** 
  - **Before:** The default secret key fallback was `"kunci_rahasia_bank_sampah"`.
  - **After:** The default secret key fallback was changed to `"kunci_rahasia_pothole"`.

### 2. CRUD Endpoints Replaced (`/sampah` to `/reports`)
All endpoints that previously handled operations on the `sampah` table were updated to interact with the `reports` table.

#### A. Create Data (POST)
- **Before:** `POST /sampah`
  - Expected `nama_sampah` from the request body.
  - Inserted data into the `sampah` table: `INSERT INTO sampah (nama_sampah, pic) VALUES (?, ?)`.
- **After:** `POST /reports`
  - Now expects `jalan` and `level_kerusakan` from the request body.
  - Inserts data into the `reports` table: `INSERT INTO reports (jalan, level_kerusakan, pic) VALUES (?, ?, ?)`.

#### B. Read All Data (GET)
- **Before:** `GET /sampah`
  - Selected all records from the `sampah` table.
- **After:** `GET /reports`
  - Selects all records from the `reports` table. The image URL mapping (`pic_url`) logic was preserved.

#### C. Read One Data by ID (GET)
- **Before:** `GET /sampah/:id`
  - Selected a single record from the `sampah` table using the provided ID.
- **After:** `GET /reports/:id`
  - Selects a single record from the `reports` table using the provided ID.

#### D. Update Data (PUT)
- **Before:** `PUT /sampah/:id`
  - Expected `nama_sampah` to update an existing record in the `sampah` table.
- **After:** `PUT /reports/:id`
  - Now expects `jalan` and `level_kerusakan` to update an existing record in the `reports` table.
  - Preserves the image upload/replacement logic.

#### E. Delete Data (DELETE)
- **Before:** `DELETE /sampah/:id`
  - Deleted records from the `sampah` table and their associated images from the `uploads/` folder.
- **After:** `DELETE /reports/:id`
  - Deletes records from the `reports` table and their associated images from the `uploads/` folder.

---

> [!NOTE]
> The `/login` and `/login-face` routes remained unchanged, as well as the database connection initialization in `db.js`. Ensure that the MySQL database has been updated with a `reports` table matching the new schema (`id`, `jalan`, `level_kerusakan`, `pic`).
