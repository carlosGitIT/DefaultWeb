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

# 3. Obtener el commit previo al actual en master
echo "3. Obteniendo el commit anterior en '$BRANCH_MASTER'..."
PREVIOUS_COMMIT=$(git log --format="%H" -n 2 | tail -n 1)
if [ -z "$PREVIOUS_COMMIT" ]; then
  echo "Error: No se pudo obtener el commit anterior."
  exit 1
fi
echo "Commit anterior encontrado: $PREVIOUS_COMMIT"

# 4. Restaurar el archivo build.ctl a su versión del commit anterior
echo "4. Restaurando el archivo '$FILE_TO_REVERT'..."
git checkout $PREVIOUS_COMMIT -- $FILE_TO_REVERT || { echo "Error: No se pudo restaurar el archivo '$FILE_TO_REVERT'."; exit 1; }

# 5. Verificar si hay diferencias en el área de staging
echo "5. Verificando si el archivo '$FILE_TO_REVERT' tiene cambios en staging..."
if git diff --cached --quiet $FILE_TO_REVERT; then
  echo "No se detectaron cambios en '$FILE_TO_REVERT'. No se realizará commit."
else
  # 6. Hacer commit de los cambios restaurados
  echo "6. Haciendo commit de los cambios restaurados en '$FILE_TO_REVERT'..."
  git add $FILE_TO_REVERT
  git commit -m "Restore $FILE_TO_REVERT to its previous version after merge"
  
  # 7. Pushear los cambios a master
  echo "7. Pusheando los cambios a la rama '$BRANCH_MASTER'..."
  git push origin $BRANCH_MASTER || { echo "Error: No se pudo pushear los cambios a '$BRANCH_MASTER'."; exit 1; }
  echo "Cambios pusheados exitosamente."
fi

echo "Simulación completada."
