# MELNE · Cómo activar el panel de administración

El panel (`admin.html`) guarda los productos en **Supabase**, una base de datos en la nube con plan gratuito.
Cuando lo actives, todo lo que registres, edites o elimines se verá en la tienda para todos tus clientes.

Mientras no lo configures, la tienda sigue funcionando con el catálogo de siempre (`js/catalogo-inicial.js`).

---

## 1. Crear el proyecto (una sola vez)

1. Entra a <https://supabase.com> y crea una cuenta gratis.
2. Pulsa **New project**:
   - Nombre: `MELNE`
   - Contraseña de la base de datos: inventa una y guárdala.
   - Región: **South America (São Paulo)**, la más cercana a Colombia.
3. Espera 1 o 2 minutos mientras se crea.

## 2. Crear las tablas y los permisos

1. En el menú izquierdo abre **SQL Editor** y pulsa **New query**.
2. Abre el archivo `supabase/setup.sql`, copia **todo** su contenido y pégalo.
3. Pulsa **Run**. Debe aparecer *Success*.

## 3. Crear tu usuario de administrador

1. Ve a **Authentication → Users → Add user → Create new user**.
2. Escribe tu correo y una contraseña segura, y marca **Auto Confirm User**.
3. Vuelve a **SQL Editor**, pega esto (con **tu** correo) y pulsa **Run**:

   ```sql
   insert into public.administradores (user_id)
   select id from auth.users where email = 'TU_CORREO@ejemplo.com'
   on conflict do nothing;
   ```

4. Recomendado: en **Authentication → Sign In / Providers**, desactiva **Allow new users to sign up**
   para que nadie más pueda crear cuentas.

## 4. Conectar la página

1. En Supabase ve a **Project Settings → API Keys** (o **Data API**).
2. Copia:
   - **Project URL** (algo como `https://abcdxyz.supabase.co`)
   - La clave **anon public** o **publishable**. **No** uses la `service_role` / `secret`.
3. Abre `js/config.js` y pega cada valor en su lugar:

   ```js
   supabaseUrl: 'https://abcdxyz.supabase.co',
   supabaseKey: 'eyJhbGciOi...',
   ```

## 5. Pasar tu catálogo actual a la base de datos

1. Abre `admin.html` (doble clic en el archivo, o tu página publicada + `/admin.html`).
2. Inicia sesión con el correo y la contraseña del paso 3.
3. Verás **"Tu catálogo está vacío"**. Escribe la cantidad inicial de unidades y pulsa
   **Importar catálogo actual**. Se cargan los 269 productos con sus fotos.
4. Ajusta las existencias reales de cada producto con **Editar**.

## 6. Publicar

Sube los cambios a GitHub como siempre (commit + push). Desde ese momento:

- **Tienda:** `index.html`
- **Panel:** `admin.html`. No aparece en la tienda; guarda el enlace en tus favoritos.

---

## Uso diario del panel

| Quiero… | Hago… |
|---|---|
| Agregar una loción | **Registrar producto**. Al elegir la categoría se sugiere el código siguiente. |
| Cambiar precio o existencias | **Editar** → cambio el dato → **Guardar cambios** |
| Ocultar una loción sin borrarla | **Editar** → Estado **Inactivo** |
| Marcar una loción agotada | Cantidad **0**: en la tienda sale "Agotado" y no se puede pedir. |
| Borrarla para siempre | **Eliminar** → confirmar |

- Las fotos se optimizan solas al subirlas (máx. 1000 px), así la tienda carga rápido.
- La tienda no deja pedir más unidades de las disponibles.
- En el mensaje de WhatsApp cada producto lleva su código (ej. `MEL-H075`). Así distingues,
  por ejemplo, el SUBLIME normal del SUBLIME en baúl de lujo.
