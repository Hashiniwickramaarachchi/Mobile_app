import { Response } from 'express';

export function respond(res: Response, body: any) {
  res.json(body);
}
import {HttpsError, CallableRequest} from "firebase-functions/v2/https";

export function requireUserId(request: CallableRequest): string {
  const uid = request.auth?.uid;

  if (!uid) {
    throw new HttpsError("unauthenticated", "You must be signed in.");
  }

  return uid;
}

export function requireString(value: unknown, fieldName: string): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new HttpsError("invalid-argument", `${fieldName} is required.`);
  }

  return value.trim();
}

export function requireBoolean(value: unknown, fieldName: string): boolean {
  if (typeof value !== "boolean") {
    throw new HttpsError("invalid-argument", `${fieldName} must be boolean.`);
  }

  return value;
}
