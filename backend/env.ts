import { env as loadEnv} from "custom-env";
import {z } from 'zod';

//determine app stage
process.env.APP_STAGE = process.env.APP_STAGE || 'dev'
const isProduction = process.env.APP_STAGE === 'production';
const isTesting = process.env.APP_STAGE === 'test';
const isDevelopment = process.env.APP_STAGE === 'dev';

if (isDevelopment) {
   loadEnv()
} else if (isTesting) {
    loadEnv('test');
}

export const envSchema = z.object({
  // Environment & Stage
  NODE_ENV: z.enum(['production', 'development', 'test']).default('development'),
  APP_STAGE: z.enum(['production', 'dev', 'test']).default('dev'),
  
  // Server Config
  PORT: z.coerce.number().positive().default(3000),
  DATABASE_URL: z.string().regex( /^mongodb(\+srv)?:\/\//, "DATABASE_URL must be a valid MongoDB connection string (starting with mongodb:// or mongodb+srv://)" ),
  // Auth
  JWT_SECRET: z.string().min(32, 'JWT_SECRET must be at least 32 characters for security'),
  JWT_EXPIRES_IN: z.string().default('7d'),
  
  // Password Hashing
  BCRYPT_ROUNDS: z.coerce.number().min(12).default(12),
  BECRYPT_ROTATE: z.coerce.number().min(10).max(12).default(10),

  // App Logic (Habit Tracker)
  MAX_ACTIVE_HABITS: z.coerce.number().positive().default(10),

  EMAIL_USER: z.string().email("Must be a valid email address"), 
  EMAIL_PASSWORD: z.string().min(1, "Email password cannot be empty")
});

// export envschema type
export type Env = z.infer<typeof envSchema>;
let env: Env;

// validate env file 
try {
    // pass the entire .env file for schema validation
    env = envSchema.parse(process.env); // inspecting the entire env file
    
} catch (e) {
    if (e instanceof z.ZodError) {
        console.error("Invalid environment variables ");
        console.log(JSON.stringify(e.flatten().fieldErrors, null, 3));

        // log all issues path
        e.issues.forEach(err => {
            const path = err.path.join(".");
            // log path and error message 
            console.log(`Path: ${path} => message: ${err.message}`)
        })
    //else exit 
    process.exit(1);
    }
    // other if error is not from zod , throw 
    throw (e);  
}


// export app_stages
export const isProd = () => env.APP_STAGE === 'production';
export const isDev = () => env.APP_STAGE === 'dev';
export const isTest = () => env.APP_STAGE === 'test';

// export env 
export { env };
export default env;