# API v1

La API es de solo lectura y devuelve JSON.

## Casos

- `GET /api/v1/cases`
- `GET /api/v1/cases/:id`

## Evidencias

- `GET /api/v1/evidences`
- `GET /api/v1/evidences/:id`
- `GET /api/v1/evidences/:evidence_id/custody_movements`

El último endpoint devuelve la evidencia y su historial de cadena de custodia.

## Reporte desde el back-office

Desde el detalle de una evidencia se puede abrir `Exportar informe`.
El reporte muestra los datos de la evidencia y todos sus movimientos de custodia. El botón `Imprimir / Guardar PDF` utiliza la función de impresión del navegador, por lo que no requiere agregar una gema extra para PDF.
