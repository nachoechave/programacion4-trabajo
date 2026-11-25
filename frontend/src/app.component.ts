import { Component, inject, signal, computed, OnInit } from '@angular/core';
import { HttpErrorResponse } from '@angular/common/http';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { CustodyApiService, CaseRecord, Evidence, Movement, Profile } from './custody-api.service';

@Component({
 selector:'app-root',standalone:true,imports:[CommonModule,FormsModule],
 templateUrl:'./app.component.html'
})
export class AppComponent implements OnInit {
 private api=inject(CustodyApiService);
 profile=signal<Profile|null>(null);
 canCreate=computed(()=>this.profile()?.role==='admin');
 token=signal(!!sessionStorage.getItem('dc_token'));
 loading=signal(false); saving=signal(false); error=signal(''); success=signal('');
 page=signal<'overview'|'cases'|'evidences'>('overview');
 cases=signal<CaseRecord[]>([]); evidences=signal<Evidence[]>([]);
 selected=signal<Evidence|null>(null); movements=signal<Movement[]>([]);
 email='';password=''; search=''; showCreate=signal(false);
 newCase={code:'',title:'',description:'',status:'open',opened_at:new Date().toISOString().slice(0,10)};
 get filteredCases(){const q=this.search.toLowerCase();return this.cases().filter(c=>(c.code+' '+c.title).toLowerCase().includes(q));}
 get filteredEvidences(){const q=this.search.toLowerCase();return this.evidences().filter(e=>(e.code+' '+e.name+' '+e.case.title).toLowerCase().includes(q));}
 analysisCount(){return this.evidences().filter(e=>e.status==='under_analysis').length;}
 ngOnInit(){if(this.token()) void this.load();}
 message(e:unknown){if(e instanceof HttpErrorResponse){if(e.status===401){if(this.token()){void this.logout();return 'Tu sesión venció. Ingresá nuevamente.';}return (e.error as {error?:string}|null)?.error||'Credenciales inválidas';}if(e.status===0)return 'No se pudo conectar con Rails. Revisá la API y el proxy.';const body=e.error as {error?:string;errors?:string[]}|null;return body?.errors?.join(' · ')||body?.error||'Error HTTP '+e.status;}return 'Ocurrió un error inesperado.';}
 async login(){if(this.saving())return;this.error.set('');this.saving.set(true);try{const data=await this.api.login(this.email,this.password);sessionStorage.setItem('dc_token',data.token);this.token.set(true);this.password='';await this.load();}catch(e){this.error.set(this.message(e));}finally{this.saving.set(false);}}
 async logout(){const t=sessionStorage.getItem('dc_token');sessionStorage.removeItem('dc_token');this.token.set(false);this.profile.set(null);this.showCreate.set(false);this.movements.set([]);this.page.set('overview');this.search='';this.success.set('');this.newCase={code:'',title:'',description:'',status:'open',opened_at:new Date().toISOString().slice(0,10)};this.cases.set([]);this.evidences.set([]);this.selected.set(null);if(t){try{await this.api.logout(t);}catch{}}}
 async load(){this.loading.set(true);this.error.set('');try{const [profile,cases,evidences]=await Promise.all([this.api.profile(),this.api.cases(),this.api.evidences()]);if(!this.token())return;this.profile.set(profile);this.cases.set(cases);this.evidences.set(evidences);}catch(e){this.error.set(this.message(e));}finally{this.loading.set(false);}}
 navigate(p:'overview'|'cases'|'evidences'){this.page.set(p);this.search='';this.selected.set(null);this.error.set('');this.success.set('');}
 async detail(e:Evidence){this.selected.set(e);this.movements.set([]);this.loading.set(true);this.error.set('');try{const result=await this.api.history(e.id);if(this.token()&&this.selected()?.id===e.id)this.movements.set(result.custody_movements);}catch(err){this.error.set(this.message(err));}finally{this.loading.set(false);}}
 async createCase(){if(!this.canCreate()||this.saving()||!this.newCase.code.trim()||!this.newCase.title.trim()||!this.newCase.opened_at)return;this.saving.set(true);this.error.set('');this.success.set('');try{await this.api.createCase(this.newCase);this.showCreate.set(false);this.newCase={code:'',title:'',description:'',status:'open',opened_at:new Date().toISOString().slice(0,10)};await this.load();this.success.set('Caso registrado correctamente en PostgreSQL.');}catch(e){this.error.set(this.message(e));}finally{this.saving.set(false);}}
}
