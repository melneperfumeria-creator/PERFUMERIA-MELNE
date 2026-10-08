-- =====================================================
-- MELNE · Configuración de la base de datos en Supabase
-- Copia TODO este archivo en Supabase → SQL Editor → Run.
-- Se puede ejecutar varias veces sin problema.
-- =====================================================

-- ---------- Tabla de productos ----------
create table if not exists public.productos (
    id             bigint generated always as identity primary key,
    codigo         text not null unique,
    nombre         text not null check (length(trim(nombre)) > 0),
    categoria      text not null check (categoria in ('Hombre', 'Mujer', 'Lujo')),
    descripcion    text not null check (length(trim(descripcion)) > 0),
    precio         integer not null check (precio > 0),
    cantidad       integer not null check (cantidad >= 0),
    imagen         text,
    etiqueta       text,
    estado         text not null default 'Activo' check (estado in ('Activo', 'Inactivo')),
    creado_en      timestamptz not null default now(),
    actualizado_en timestamptz not null default now()
);

create or replace function public.tocar_actualizado_en()
returns trigger language plpgsql as $$
begin
    new.actualizado_en = now();
    return new;
end;
$$;

drop trigger if exists productos_actualizado_en on public.productos;
create trigger productos_actualizado_en
    before update on public.productos
    for each row execute function public.tocar_actualizado_en();

-- ---------- Administradores ----------
-- Solo las cuentas que estén en esta tabla pueden modificar el catálogo.
create table if not exists public.administradores (
    user_id uuid primary key references auth.users (id) on delete cascade
);
alter table public.administradores enable row level security;

create or replace function public.es_admin()
returns boolean language sql stable security definer set search_path = public as $$
    select exists (select 1 from public.administradores where user_id = auth.uid());
$$;
grant execute on function public.es_admin() to anon, authenticated;

-- ---------- Permisos de productos ----------
alter table public.productos enable row level security;
grant select on public.productos to anon, authenticated;
grant insert, update, delete on public.productos to authenticated;

drop policy if exists "Ver productos" on public.productos;
create policy "Ver productos" on public.productos
    for select to anon, authenticated
    using (estado = 'Activo' or public.es_admin());

drop policy if exists "Admin registra productos" on public.productos;
create policy "Admin registra productos" on public.productos
    for insert to authenticated with check (public.es_admin());

drop policy if exists "Admin edita productos" on public.productos;
create policy "Admin edita productos" on public.productos
    for update to authenticated using (public.es_admin()) with check (public.es_admin());

drop policy if exists "Admin elimina productos" on public.productos;
create policy "Admin elimina productos" on public.productos
    for delete to authenticated using (public.es_admin());

-- ---------- Imágenes (Storage) ----------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('productos', 'productos', true, 5242880, array['image/jpeg', 'image/png'])
on conflict (id) do update
    set public = excluded.public,
        file_size_limit = excluded.file_size_limit,
        allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "Admin ve imagenes" on storage.objects;
create policy "Admin ve imagenes" on storage.objects
    for select to authenticated using (bucket_id = 'productos' and public.es_admin());

drop policy if exists "Admin sube imagenes" on storage.objects;
create policy "Admin sube imagenes" on storage.objects
    for insert to authenticated with check (bucket_id = 'productos' and public.es_admin());

drop policy if exists "Admin cambia imagenes" on storage.objects;
create policy "Admin cambia imagenes" on storage.objects
    for update to authenticated using (bucket_id = 'productos' and public.es_admin());

drop policy if exists "Admin borra imagenes" on storage.objects;
create policy "Admin borra imagenes" on storage.objects
    for delete to authenticated using (bucket_id = 'productos' and public.es_admin());

-- =====================================================
-- ÚLTIMO PASO (ejecútalo aparte, DESPUÉS de crear tu usuario
-- en Authentication → Users). Cambia el correo por el tuyo:
--
-- insert into public.administradores (user_id)
-- select id from auth.users where email = 'TU_CORREO@ejemplo.com'
-- on conflict do nothing;
-- =====================================================
