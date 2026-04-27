# EstudioIA-Pokedex

Aplicación iOS desarrollada en SwiftUI que consume la API pública de PokeAPI mostrando listado paginado y vista de detalle con manejo completo de estados.

- Consumo de API: GET https://pokeapi.co/api/v2/pokemon?limit=&offset=

- Estados implementados: Loading / Error con botón de reintento / Estado vacío

- Paginación: 20 elementos por página y Botones "Anterior" / "Siguiente"

- Listado: Cada Pokémon muestra -> Imagen (AsyncImage), Nombre y ID visible

- Detalles de cada Pokemon:Nombre, ID, Sprite, Tipos, Altura, Peso

- Errores controlados

