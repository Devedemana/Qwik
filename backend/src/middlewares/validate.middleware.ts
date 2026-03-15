import { Request, Response, NextFunction } from 'express';
import { ZodObject } from 'zod';

export const validateBody = (schema: ZodObject) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const result = schema.safeParse(req.body);

    if (!result.success) {
      return res.status(400).json({
        error: 'Invalid body',
        details: result.error.issues.map((iss) => ({
          path: iss.path.join('.'),
          message: iss.message
        }))
      });
    }

    // Attach the cleaned data back to req.body
    req.body = result.data;
    next();
  };
};

  
 export const validateQuery = (schema: ZodObject) => 
    async (req: Request, res: Response, next: NextFunction) => {
      const result = schema.safeParse(req.query); 

      // incase it fails
      if (!result.success) {
        return res.status(400).json({
          error: 'Invalid query',
          details: result.error.issues.map((issue) => ({
            path: issue.path.join('.'),
            message: issue.message
          }))
        })
      }

      // other than that
      req.query = result.data; 

      next()
   };
     
  
  export const validateParams = (schema: ZodObject) => 
      async (req: Request, res: Response, next: NextFunction) =>{
        const result = schema.safeParse(req.params); 
        
        if (!result.success) {
          return res.status(400).json({
            error: 'Invalid parameters',
            details: result.error.issues.map((issue) => ({
              path: issue.path.join('.'),
              message: issue.message
            }))
          })
        }

        // if no error 
        req.params = result.data; 

        next();
  };