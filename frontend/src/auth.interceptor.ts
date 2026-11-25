import { HttpInterceptorFn } from '@angular/common/http';
export const authInterceptor: HttpInterceptorFn = (req,next) => {
 const token = sessionStorage.getItem('dc_token');
 return next(token && req.url.startsWith('/api/v1/') && !req.headers.has('Authorization') && req.url !== '/api/v1/login' ? req.clone({setHeaders:{Authorization:'Bearer '+token}}) : req);
};
