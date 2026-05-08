# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

LSManager is a Rails 8.1 learning management system (LMS) for managing students enrolled in courses/lessons, tracking learning progress, and sending templated emails. The UI and data are in Japanese. Authentication is admin-only (no student-facing login).

## Commands

```bash
# Setup
bin/setup

# Development server
bin/dev

# Tests
bin/rails test                        # all tests
bin/rails test test/models/student_test.rb  # single file
bin/rails test test/models/student_test.rb:42  # single test by line

# Linting
bin/rubocop

# Database
bin/rails db:migrate
bin/rails db:seed                     # creates admin@example.com / password123 + sample data

# Console
bin/rails console
```

## Architecture

### Authentication
All controllers inherit `ApplicationController`, which enforces `require_login` via `session[:admin_id]`. `SessionsController` skips this filter. `Admin` uses `has_secure_password`. Two roles: `general` and `super_admin` — `require_super_admin` is a separate guard called explicitly in controllers that need it.

### Data Model
- `Student` — the central entity; holds a large set of JFA (Japan Football Association) registration fields imported from CSV.
- `Course` → `Lesson` (ordered by `position`) — course content hierarchy.
- `StudentCourseEnrollment` — join table linking students to courses (`enrolled_on` date).
- `Progress` — per-student, per-lesson status (`not_started` / `in_progress` / `completed`); auto-sets `completed_at` on first completion via `before_save`.
- `EmailTemplate` — reusable mail templates with `{{name}}`, `{{student_code}}`, `{{department}}` placeholders rendered via `render_for(student)`.
- `EmailLog` — audit trail for every email sent or failed; `email_template_id` is nullable (template may be deleted).
- `Admin` — system users only; not related to Student.

### CSV Import Flow
`StudentsController#import` is a two-step process using a temp file + session:
1. **Preview step**: file is saved to `tmp/csv_import_<hex>.csv`, path stored in `session[:csv_tmp_path]`, first 5 rows rendered in `import_preview` view.
2. **Confirm step**: `params[:confirm]` triggers `Student.import_csv_from_path` using the stored path, then deletes the temp file.

`Student::CSV_COLUMNS` maps Japanese column headers → model attributes and drives both import and export.

### Email Sending
`EmailTemplatesController#send_email` sends to selected student IDs; `#bulk_send` sends to `Student.active`. Both use `StudentMailer.template_email` with `deliver_later` (backed by Solid Queue) and record an `EmailLog` entry regardless of success/failure.

### Frontend
Hotwire (Turbo + Stimulus) with importmap. The CSV import form has Turbo disabled (`data-turbo="false"`) to ensure proper file upload and redirect behavior.

Pagination via Kaminari (`page(params[:page])`).
