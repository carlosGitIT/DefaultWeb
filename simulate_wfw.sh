#!/bin/bash

# Configuracion inicial
BRANCH_MASTER="master"
FILE_TO_REVERT="build.ctl"

echo ""
echo "Restaurar el archivo '$FILE_TO_REVERT' a su version original en la rama '$BRANCH_MASTER' ..."
echo ""

# 1. Verificar que estamos en el directorio correcto
echo "  1. Verificando repositorio..."
if ! git status &>/dev/null; then
  echo "  Error: Este script debe ejecutarse dentro de un repositorio Git."
  exit 1
fi

echo ""

# 2. Cambiar a la rama master
echo "  2. Cambiando a la rama '$BRANCH_MASTER'..."
git checkout $BRANCH_MASTER || { echo "  Error: No se pudo cambiar a la rama '$BRANCH_MASTER'."; exit 1; }

echo ""

# 3. Obtener el commit previo al actual en master
echo "  3. Obteniendo el commit anterior en '$BRANCH_MASTER'..."
PREVIOUS_COMMIT=$(git rev-parse HEAD^)
if [ -z "$PREVIOUS_COMMIT" ]; then
  echo "  Error: No se pudo obtener el commit anterior."
  exit 1
fi

echo ""
echo "  Commit anterior encontrado: $PREVIOUS_COMMIT"
echo ""

# 4. Restaurar el archivo build.ctl a su version del commit anterior
echo "  4. Restaurando el archivo '$FILE_TO_REVERT'..."
git show "$PREVIOUS_COMMIT:$FILE_TO_REVERT" > $FILE_TO_REVERT || { 
  echo "  Error: No se pudo restaurar el archivo '$FILE_TO_REVERT'.";
  exit 1;
}

echo ""

# 5. Verificar si hay cambios
echo "  5. Verificando si el archivo '$FILE_TO_REVERT' tiene cambios..."
echo ""

if git diff --staged --quiet $FILE_TO_REVERT; then
  echo "  No se detectaron cambios en '$FILE_TO_REVERT'. No se realizará commit."
else
  # 6. Hacer commit de los cambios restaurados
  echo "  6. Haciendo commit de los cambios restaurados en '$FILE_TO_REVERT'..."
  git add $FILE_TO_REVERT
  git commit -m "Restore $FILE_TO_REVERT to its previous version after merge"
  
  # 7. Pushear los cambios a master
  echo "  7. Pusheando los cambios a la rama '$BRANCH_MASTER'..."
  git push origin $BRANCH_MASTER || { echo "  Error: No se pudo pushear los cambios a '$BRANCH_MASTER'."; exit 1; }
  echo "  Cambios pusheados exitosamente."
fi

echo ""
echo "Simulacion completada."