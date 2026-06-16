export const TYPE = {
  USER: 'user',
  ALERT: 'alert'
} as const;
export type AlertStatus = "pending" | "checked";
export type AlertSeverity = "low" | "medium" | "high";

export interface UserAccount {
  username: string;
  createdAt?: FirebaseFirestore.FieldValue;
  updatedAt?: FirebaseFirestore.FieldValue;
}

export interface Profile {
  guardianName: string;
  elderlyName: string;
  age: string;
  disabilities: string;
  updatedAt?: FirebaseFirestore.FieldValue;
}

export interface EmergencyContact {
  name: string;
  phone: string;
  relationship: string;
  createdAt?: FirebaseFirestore.FieldValue;
  updatedAt?: FirebaseFirestore.FieldValue;
}

export interface Alert {
  type: string;
  status: AlertStatus;
  severity: AlertSeverity;
  occurredAt: string;
  incidentDetail: string;
  createdAt?: FirebaseFirestore.FieldValue;
  updatedAt?: FirebaseFirestore.FieldValue;
}

export interface Settings {
  fallDetected: boolean;
  inactivity: boolean;
  wandering: boolean;
  updatedAt?: FirebaseFirestore.FieldValue;
}
