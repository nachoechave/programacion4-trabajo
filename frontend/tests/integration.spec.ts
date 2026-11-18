import { test, expect, type Page } from '@playwright/test';

const cases = [
  {id:1,code:'CAS-001',title:'Incidente de seguridad',description:'Equipo de oficina',status:'open',opened_at:'2026-11-18',closed_at:null}
];
const evidences = [
  {id:2,code:'EVD-001',name:'Disco SSD',description:'Imagen forense',status:'under_analysis',collected_at:'2026-11-18',location:'Laboratorio',case:{id:1,code:'CAS-001',title:'Incidente de seguridad'},evidence_type:{id:1,name:'SSD'},current_custodian:{id:1,name:'Juan',email:'juan@example.com'}}
];
async function mockApi(page:Page, opts:{createError?:boolean;loginError?:boolean}={}) {
  const records=cases.map(c=>({...c}));
  await page.route('**/api/v1/**', async route=>{
    const request=route.request();
    const path=new URL(request.url()).pathname;
    const method=request.method();
    const json=(status:number,body:unknown)=>route.fulfill({status,contentType:'application/json',body:JSON.stringify(body)});
    if(path==='/api/v1/login'&&method==='POST')return json(opts.loginError?401:201,opts.loginError?{error:'Credenciales inválidas'}:{token:'test-token',token_type:'Bearer',expires_in:86400});
    if(path==='/api/v1/logout'&&method==='DELETE')return route.fulfill({status:204,body:''});
    if(path==='/api/v1/cases'&&method==='GET')return json(200,records);
    if(path==='/api/v1/evidences'&&method==='GET')return json(200,evidences);
    if(path==='/api/v1/evidences/2/custody_movements'&&method==='GET')return json(200,{evidence:{id:2,code:'EVD-001',name:'Disco SSD'},custody_movements:[{id:3,from_user:null,to_user:{name:'Juan'},performed_by:{name:'Admin'},transferred_at:'2026-11-18T10:00:00Z',reason:'Registro inicial',notes:null}]});
    if(path==='/api/v1/cases'&&method==='POST'){
      if(opts.createError)return json(422,{errors:['Code ya está en uso']});
      const body=request.postDataJSON() as {case:{code:string;title:string;description:string;status:string;opened_at:string}};
      const created={id:records.length+1,...body.case,closed_at:null};
      records.push(created);
      return json(201,created);
    }
    return json(404,{error:'No encontrado'});
  });
}
async function login(page:Page) {
  await page.getByLabel('Correo electrónico').fill('admin@example.com');
  await page.getByLabel('Contraseña').fill('password123');
  await page.getByRole('button',{name:/Iniciar sesión/}).click();
  await expect(page.getByRole('heading',{name:'Panel general'})).toBeVisible();
}
test('login, creación persistente y consulta del historial',async ({page})=>{
  await mockApi(page);
  await page.goto('/');
  await login(page);
  await expect(page.getByText('Incidente de seguridad')).toBeVisible();
  await page.getByRole('button',{name:/Investigaciones/}).click();
  await page.getByRole('button',{name:/Nuevo caso/}).click();
  await page.getByLabel('Código *').fill('CAS-002');
  await page.getByLabel('Título *').fill('Investigación nueva');
  await page.getByRole('button',{name:'Guardar investigación'}).click();
  await expect(page.getByText('Caso registrado correctamente en PostgreSQL.')).toBeVisible();
  await expect(page.getByText('Investigación nueva')).toBeVisible();
  await page.getByRole('button',{name:/Evidencias/}).click();
  await page.getByRole('button',{name:/Ver historial/}).click();
  await expect(page.getByText('Registro inicial')).toBeVisible();
  await page.getByRole('button',{name:/Cerrar sesión/}).click();
  await expect(page.getByRole('heading',{name:'Bienvenido'})).toBeVisible();
});
test('validación del servidor 422 sin perder formulario',async ({page})=>{
  await mockApi(page,{createError:true});
  await page.goto('/');
  await login(page);
  await page.getByRole('button',{name:/Investigaciones/}).click();
  await page.getByRole('button',{name:/Nuevo caso/}).click();
  await page.getByLabel('Código *').fill('CAS-001');
  await page.getByLabel('Título *').fill('Duplicado');
  await page.getByRole('button',{name:'Guardar investigación'}).click();
  await expect(page.getByRole('alert')).toContainText('Code ya está en uso');
  await expect(page.getByLabel('Título *')).toHaveValue('Duplicado');
});
test('rechazo de credenciales muestra error',async ({page})=>{
  await mockApi(page,{loginError:true});
  await page.goto('/');
  await page.getByLabel('Correo electrónico').fill('admin@example.com');
  await page.getByLabel('Contraseña').fill('incorrecta');
  await page.getByRole('button',{name:/Iniciar sesión/}).click();
  await expect(page.getByRole('alert')).toContainText('Credenciales inválidas');
  await expect(page.getByRole('heading',{name:'Bienvenido'})).toBeVisible();
});
