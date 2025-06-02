import os
import yaml

# Ruta al docker-compose.yml
DOCKER_COMPOSE_PATH = 'docker-compose.yml'
PROYECTO_ROOT = os.path.dirname(os.path.abspath(DOCKER_COMPOSE_PATH))

# Instrucciones mínimas válidas de un Dockerfile
DOCKERFILE_INSTRUCCIONES = ['FROM']

def es_dockerfile_valido(path):
    try:
        with open(path, 'r') as f:
            contenido = f.read()
            return any(instr in contenido.upper() for instr in DOCKERFILE_INSTRUCCIONES)
    except Exception:
        return False

def main():
    with open(DOCKER_COMPOSE_PATH, 'r') as f:
        compose = yaml.safe_load(f)

    services = compose.get('services', {})
    errores = []

    for nombre, servicio in services.items():
        build = servicio.get('build')
        if build:
            if isinstance(build, dict):
                contexto = build.get('context', '')
            else:
                contexto = build

            path_dockerfile = os.path.join(PROYECTO_ROOT, contexto, 'Dockerfile')
            if not os.path.isfile(path_dockerfile):
                errores.append(f"[❌] {nombre}: Dockerfile no encontrado en {path_dockerfile}")
            elif not es_dockerfile_valido(path_dockerfile):
                errores.append(f"[⚠️] {nombre}: Dockerfile en {path_dockerfile} no parece válido (falta instrucción FROM)")
            else:
                print(f"[✅] {nombre}: Dockerfile válido encontrado en {path_dockerfile}")

    if errores:
        print("\nResumen de errores:")
        for e in errores:
            print(e)
    else:
        print("\n🚀 Todos los Dockerfile fueron encontrados y son válidos.")

if __name__ == '__main__':
    main()
