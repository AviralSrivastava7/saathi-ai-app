import { NextRequest, NextResponse } from 'next/server';
import { isValidEmail, sanitizeString } from '@/utils/security';

const rateLimitMap = new Map<string, { count: number; lastReset: number }>();
const RATE_LIMIT_WINDOW = 60 * 1000;
const MAX_REQUESTS = 5;

function checkRateLimit(ip: string): boolean {
    const now = Date.now();
    const rateData = rateLimitMap.get(ip) || { count: 0, lastReset: now };

    if (now - rateData.lastReset > RATE_LIMIT_WINDOW) {
        rateData.count = 1;
        rateData.lastReset = now;
    } else {
        rateData.count++;
    }

    rateLimitMap.set(ip, rateData);
    return rateData.count <= MAX_REQUESTS;
}

export async function POST(req: NextRequest) {
    const forwarded = req.headers.get('x-forwarded-for');
    const ip = typeof forwarded === 'string' ? forwarded.split(',')[0] : 'anonymous';

    if (!checkRateLimit(ip)) {
        return NextResponse.json(
            { error: 'Too many requests. Please try again later.' },
            { status: 429 }
        );
    }

    try {
        const body = await req.json();
        const { name, email, message } = body;

        if (!name || typeof name !== 'string' || name.length > 100) {
            return NextResponse.json({ error: 'Invalid name' }, { status: 400 });
        }
        if (!email || !isValidEmail(email)) {
            return NextResponse.json({ error: 'Invalid email' }, { status: 400 });
        }
        if (!message || typeof message !== 'string' || message.length > 2000) {
            return NextResponse.json({ error: 'Invalid message' }, { status: 400 });
        }

        const safeName = sanitizeString(name);
        const safeMessage = sanitizeString(message);

        console.log(`Contact form: ${safeName} (${email}): ${safeMessage}`);

        return NextResponse.json({ success: true, message: 'Message sent securely.' });
    } catch {
        return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
    }
}
