import { Request, Response, NextFunction } from 'express';
import { auth } from '../firebase';

export interface AuthedRequest extends Request {
  user?: { uid: string; [key: string]: any };
}

export async function requireAuth(req: AuthedRequest, res: Response, next: NextFunction) {
  try {
    const header = (req.get('Authorization') || req.get('authorization') || '').toString();
    const match = header.match(/^Bearer\s+(.*)$/i);
    if (!match) {
      return res.status(401).json({ error: 'Missing or invalid Authorization header' });
    }
    const idToken = match[1];
    const decoded = await auth.verifyIdToken(idToken);
    req.user = decoded as any;
    return next();
  } catch (err: any) {
    return res.status(401).json({ error: 'Unauthorized', details: err?.message || String(err) });
  }
}
