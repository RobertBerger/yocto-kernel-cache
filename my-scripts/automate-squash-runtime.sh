#!/bin/bash

# You might want to check step 7 for the commit message!!!

# =====================================================================
# 🛡️ SAFETY FIRST: Exit instantly if any single command fails
# =====================================================================
set -e

# =====================================================================
# 🔍 PARAMETER CHECK: Ensure BRANCH_VER is passed to the script
# =====================================================================
if [ -z "${1}" ]; then
    echo "❌ CRITICAL ERROR: Target version parameter is missing!" >&2
    echo "Usage: ./${0##*/} <version>" >&2
    echo "e.g.:  ./${0##*/} 6.18" >&2
    echo "e.g.:  ./${0##*/} 7.2" >&2
    exit 1
fi

export BRANCH_VER="${1}"

# =====================================================================
# 🔀 SELF-COPY METADATA GUARD (Bypasses Workspace Overwriting)
# =====================================================================
# If we are running inside the repository directory, copy the script to
# /tmp and execute it from there so Git branch changes won't delete it.
SCRIPT_REALPATH=$(realpath "${0}")
TMP_SCRIPT="/tmp/automate-squash-runtime.sh"

if [ "${SCRIPT_REALPATH}" != "${TMP_SCRIPT}" ]; then
    echo "🛡️ Protecting execution context... Copying script to safely execute out of /tmp."
    cp "${SCRIPT_REALPATH}" "${TMP_SCRIPT}"
    chmod +x "${TMP_SCRIPT}"
    exec "${TMP_SCRIPT}" "${BRANCH_VER}"
fi

# ---------------------------------------------------------------------
# Beyond this point, the script runs safely out of /tmp
# ---------------------------------------------------------------------

echo "============================================================="
echo " STARTING SQUASH PIPELINE FOR TARGET: yocto-${BRANCH_VER}"
echo "============================================================="

# 1. Resolve repository layout names dynamically
REPO_DIR=$(basename "$(pwd)")

# 2. Step out one level to create physical tarball archive backup
echo "1. Stepping out one level to create physical tarball archive backup..."
cd ..
tar czvf "${REPO_DIR}-${BRANCH_VER}.working.final.tar.gz" "${REPO_DIR}"

# Hard Safety Check: Stop everything if the tarball creation failed
if [ ! -f "${REPO_DIR}-${BRANCH_VER}.working.final.tar.gz" ]; then
    echo "❌ CRITICAL ERROR: Tarball backup file was not created! Aborting." >&2
    exit 1
fi

echo "2. Tarball verified. Returning to repository context..."
cd "${REPO_DIR}"

echo "3. Switching target execution context to branch: yocto-${BRANCH_VER}..."
git checkout "yocto-${BRANCH_VER}"

echo "4. Creating and pushing remote tracking fallback branch..."
git branch "yocto-${BRANCH_VER}-backup-before-squash"
git push origin "yocto-${BRANCH_VER}-backup-before-squash"

echo "5. Executing soft reset to upstream baseline..."
git reset --soft "official-upstream/yocto-${BRANCH_VER}"

echo "6. Verifying working directory status..."
git status

echo "7. Creating compressed single-state commit..."
git commit -m "added: phyboard-pollux-imx8mp-3-standard, pollux-standard"

echo "8. Safely force-pushing clean history to origin server..."
git push origin HEAD --force-with-lease

echo "🎉 SQUASH PIPELINE COMPLETED SUCCESSFULLY!"
echo "---------------------------------------"
git log --oneline -n 5
echo "---------------------------------------"

# =====================================================================
# 🧹 CLEANUP DELETIONS (Only reached if force-push succeeded)
# =====================================================================
echo "9. Cleaning up temporary tracking branches..."
git push origin --delete "yocto-${BRANCH_VER}-backup-before-squash"
git branch -D "yocto-${BRANCH_VER}-backup-before-squash"

echo "10. Returning repository safely back to master branch context..."
git checkout master

# Clean up the runtime memory script clone
rm -f "${TMP_SCRIPT}"

echo "✅ All temporary backups removed. History successfully squashed for version ${BRANCH_VER}!"

