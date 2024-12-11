#!/bin/bash

# Configuración inicial
echo "Restaurar build.ctl con contenido de archivo base si se detectan cambios"
#BRANCH_MASTER="feature/a1"
FILE_TO_REVERT="build.ctl"
BASE_FILE="base_build.ctl"

#0. verificar el parametro de entrada, en este caso sera la branch donde se restaurara el archivo deseado
if [ -z "$1" ]; then
  echo "Error no se ha proporcionado un parametro con la branch a validar el archivo deseado "
  echo "Uso: $0 <nombre_de_la_rama>"
  exit 1
fi

# 1. Verificar que estamos en el directorio correcto
echo "1. Verificando repositorio..."
if ! git status &>/dev/null; then
  echo "Error: Este script debe ejecutarse dentro de un repositorio Git."
  exit 1
fi

#$(git rev-parse --abbrev-ref HEAD)
BRANCH_TO_UPDATE="$1"

# 2. Cambiar a la rama master
echo "2. Cambiando a la rama '$BRANCH_TO_UPDATE'..."
git checkout $BRANCH_TO_UPDATE || { echo "Error: No se pudo cambiar a la rama '$BRANCH_TO_UPDATE'."; exit 1; }

# 3. Actualizar el repositorio local
echo "3. Actualizando el repositorio local con los últimos cambios..."
git pull origin $BRANCH_TO_UPDATE || { echo "Error: No se pudo actualizar el repositorio local."; exit 1; }

# 4. Verificar si el archivo build.ctl tiene cambios en comparación con la última versión en el repositorio remoto
echo "4. Verificando si '$FILE_TO_REVERT' ha cambiado..."
if git diff HEAD~1 HEAD --name-only | grep -q "^$FILE_TO_REVERT$"; then
  echo "Se detectaron cambios en '$FILE_TO_REVERT'. Restaurando archivo desde '$BASE_FILE'..."
  
  # 5. Restaurar el archivo con el contenido del archivo base
  cp $BASE_FILE $FILE_TO_REVERT || { echo "Error: No se pudo copiar el archivo base."; exit 1; }
  echo "El archivo '$FILE_TO_REVERT' ha sido restaurado con el contenido de '$BASE_FILE'."

  # 6. Hacer commit de los cambios restaurados
  echo "6. Haciendo commit de los cambios restaurados en '$FILE_TO_REVERT'..."
  git add $FILE_TO_REVERT
  git commit -m "Restore $FILE_TO_REVERT with content from $BASE_FILE"
  
  # 7. Pushear los cambios a master
  echo "7. Pusheando los cambios a la rama '$BRANCH_TO_UPDATE'..."
  git push origin $BRANCH_TO_UPDATE || { echo "Error: No se pudo pushear los cambios a '$BRANCH_TO_UPDATE'."; exit 1; }
  echo "Cambios pusheados exitosamente."
else
  echo "No se detectaron cambios en '$FILE_TO_REVERT'. No es necesario restaurar."
fi

echo "Proceso completado."

