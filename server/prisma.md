# Prisma Types Generation Guide

This document explains how to properly generate TypeScript types after modifying the Prisma schema. Following these steps ensures the application's type safety remains intact when working with the PostgreSQL database.

## What is Prisma?

[Prisma](https://www.prisma.io/) is an ORM (Object-Relational Mapping) for Node.js and TypeScript that helps you interact with your database through a type-safe API.

## Generating Types After Schema Changes

When you modify your Prisma schema (`schema.prisma`), you need to regenerate the Prisma Client to ensure the application has access to the latest types that match your schema. The `npm start` command regenerates the types automatically before starting the application, but you can also do it manually.

### Step 1: Modify Your Schema

Edit your `schema.prisma` file to add/modify models, fields, or relationships.

```prisma
// Example schema addition
model Task {
    id          String   @id @default(uuid())
    title       String
    description String?
    completed   Boolean  @default(false)
    createdAt   DateTime @default(now())
    updatedAt   DateTime @updatedAt
    userId      String
    user        User     @relation(fields: [userId], references: [id])
}
```

### Step 2: Generate Prisma Client

Run the following command to generate your Prisma Client with updated types:

```bash
npx prisma generate
```

This command reads your Prisma schema and generates TypeScript types in the `node_modules/.prisma/client` directory.
If you have specified a custom output directory in your `schema.prisma`, the generated files will be located there.

### Alternative: Using `npm start` Script

If you prefer, you can also use the `npm start` script to generate the Prisma Client automatically. This script is already set up to run the `prisma generate` command before starting the application.

### Step 3: Apply Database Migrations (if needed)

If your schema changes require database structure updates:

```bash
# Create a migration
npx prisma migrate dev --name describe_your_changes

# Or for direct application without migration files (development only)
npx prisma db push
```

## Best Practices

- **Version control the schema**: Always keep the `schema.prisma` file in version control
- **Descriptive migration names**: Use clear migration names that describe the changes
- **Test after generation**: Verify the application works with the new types before deploying
- **Update seeds if necessary**: If you have seed data, update it to match the new schema

## Common Issues and Solutions

- **Type errors after generation**: Make sure to restart your TypeScript server/IDE
- **Migration conflicts**: Resolve by checking migration history with `npx prisma migrate status`
- **Missing fields in types**: Ensure you've run `prisma generate` after all schema changes

## Official Documentation

- [Prisma Schema Reference](https://www.prisma.io/docs/concepts/components/prisma-schema)
- [Prisma Client Generation](https://www.prisma.io/docs/concepts/components/prisma-client/working-with-prismaclient/generating-prisma-client)
- [Prisma Migrations](https://www.prisma.io/docs/concepts/components/prisma-migrate)
- [TypeScript & Prisma](https://www.prisma.io/docs/concepts/components/prisma-client/working-with-prismaclient/type-safety)

## Quick Command Reference

```bash
# Generate Prisma Client
npx prisma generate

# Generate and start the app
npm start

# Create a migration
npx prisma migrate dev --name your_migration_name

# Apply migrations to production
npx prisma migrate deploy

# Reset database (dev only)
npx prisma migrate reset

# Format schema file
npx prisma format

# Open Prisma Studio (database GUI)
npx prisma studio
```
