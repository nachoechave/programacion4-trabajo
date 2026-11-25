import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { firstValueFrom } from 'rxjs';
export interface CaseRecord {id:number;code:string;title:string;description:string;status:string;opened_at:string;closed_at:string|null}
export interface Evidence {id:number;code:string;name:string;description:string;status:string;collected_at:string;location:string;case:{id:number;code:string;title:string};evidence_type:{id:number;name:string};current_custodian:{id:number;name:string;email:string}}
export interface Movement {id:number;from_user:{name:string}|null;to_user:{name:string};performed_by:{name:string};transferred_at:string;reason:string;notes:string|null}

export interface Profile { id:number; name:string; role:'admin'|'analyst' }
@Injectable({providedIn:'root'})
export class CustodyApiService {
 private http=inject(HttpClient);
 login(email:string,password:string){return firstValueFrom(this.http.post<{token:string}>('/api/v1/login',{email,password}));}
 profile(){return firstValueFrom(this.http.get<Profile>('/api/v1/me'));}
 cases(){return firstValueFrom(this.http.get<CaseRecord[]>('/api/v1/cases'));}
 evidences(){return firstValueFrom(this.http.get<Evidence[]>('/api/v1/evidences'));}
 history(id:number){return firstValueFrom(this.http.get<{custody_movements:Movement[]}>(`/api/v1/evidences/${id}/custody_movements`));}
 createCase(record:{code:string;title:string;description:string;status:string;opened_at:string}){return firstValueFrom(this.http.post('/api/v1/cases',{case:record}));}
 logout(token:string){return firstValueFrom(this.http.delete('/api/v1/logout',{headers:{Authorization:'Bearer '+token}}));}
}
