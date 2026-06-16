# Database Structure

Placeholder for the database structure documentation.
# Firestore Database Structure

This backend stores each signed-in user's data under their Firebase Auth UID.

```text
users/
  {userId}/
    username: string
    createdAt: timestamp
    updatedAt: timestamp

    profile/
      main/
        guardianName: string
        elderlyName: string
        age: string
        disabilities: string
        updatedAt: timestamp

    emergencyContacts/
      {contactId}/
        name: string
        phone: string
        relationship: string
        createdAt: timestamp
        updatedAt: timestamp

    settings/
      main/
        fallDetected: boolean
        inactivity: boolean
        wandering: boolean
        updatedAt: timestamp

    alerts/
      {alertId}/
        type: string
        status: "pending" | "checked"
        severity: "low" | "medium" | "high"
        occurredAt: string
        incidentDetail: string
        createdAt: timestamp
        updatedAt: timestamp
```

## Security Model

- A user can read and write only their own document tree.
- Users cannot delete their root `users/{userId}` document.
- Alerts, contacts, settings, and profile data are scoped under the user.
- Cloud Functions also validate auth before writing data.
