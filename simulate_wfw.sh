#!/bin/bash

# Configuración inicial
echo "Simulación del Workflow para restaurar build.ctl a su versión previa al merge"
BRANCH_MASTER="master"
FILE_TO_REVERT="build.ctl"

# 1. Verificar que estamos en el directorio correcto
echo "1. Verificando repositorio..."
if ! git status &>/dev/null; then
  echo "Error: Este script debe ejecutarse dentro de un repositorio Git."
  exit 1
fi

# 2. Cambiar a la rama master
echo "2. Cambiando a la rama '$BRANCH_MASTER'..."
git checkout $BRANCH_MASTER || { echo "Error: No se pudo cambiar a la rama '$BRANCH_MASTER'."; exit 1; }

# 3. Verificar si el archivo fue modificado en el último commit
echo "3. Verificando si '$FILE_TO_REVERT' fue modificado en el último commit..."
if ! git diff --name-only HEAD~1 HEAD | grep -q "$FILE_TO_REVERT"; then
  echo "El archivo '$FILE_TO_REVERT' no ha sido modificado en el último commit. No se realizarán cambios."
  exit 0
fi
echo "El archivo '$FILE_TO_REVERT' fue modificado en el último commit. Procediendo..."

# 4. Obtener el commit previo al actual en master
echo "4. Obteniendo el commit anterior en '$BRANCH_MASTER'..."
PREVIOUS_COMMIT=$(git log -2 --format="%H" | tail -n 1)
if [ -z "$PREVIOUS_COMMIT" ]; then
  echo "Error: No se pudo obtener el commit anterior."
  exit 1
fi
echo "Commit anterior encontrado: $PREVIOUS_COMMIT"

# 5. Restaurar el archivo build.ctl a su versión del commit anterior
echo "5. Restaurando el archivo '$FILE_TO_REVERT'..."
git checkout $PREVIOUS_COMMIT -- $FILE_TO_REVERT || { echo "Error: No se pudo restaurar el archivo '$FILE_TO_REVERT'."; exit 1; }

# 6. Verificar si realmente hubo cambios en el archivo
echo "6. Verificando si realmente hubo cambios en el archivo restaurado..."
if git diff --staged $FILE_TO_REVERT; then
  echo "No se detectaron cambios en '$FILE_TO_REVERT' después de la restauración. No se realizará commit."
  exit 0
fi

# 7. Hacer commit de los cambios restaurados
echo "7. Haciendo commit de los cambios restaurados en '$FILE_TO_REVERT'..."
git add $FILE_TO_REVERT
git commit -m "Restore $FILE_TO_REVERT to its previous version after merge"

# 8. Pushear los cambios a master
echo "8. Pusheando los cambios a la rama '$BRANCH_MASTER'..."
git push origin $BRANCH_MASTER || { echo "Error: No se pudo pushear los cambios a '$BRANCH_MASTER'."; exit 1; }
echo "Cambios pusheados exitosamente."

echo "Simulación completada."
