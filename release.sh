#!/bin/sh
# Usage: ./release.sh (NEW_VERSION | tag)
set -e

CHANGELOG="CHANGELOG.md"
SPEC="package.json"
VERSION_RE='^(\s*"version":\s*")(.*)("[^"].*)$'

defer_reset_to=""
defer_reset_hard_to=""
defer_tag_delete=""
clean_up() {
    if [ "$?" -eq 0 ]; then
        exit 0
    fi
    printf '%s\n' "failed!"

    if [ -n "$defer_reset_hard_to" ]; then
        printf '%s\n' "reverting changes..."
        git reset --hard "$defer_reset_hard_to"
    fi
    if [ -n "$defer_reset_to" ]; then
        printf '%s\n' "unstaging all changes..."
        git reset "$defer_reset_to"
    fi
    if [ -n "$defer_tag_delete" ]; then
        printf '%s\n' "deleting new tag..."
        git tag -d "$defer_tag_delete"
    fi
}
trap clean_up EXIT

spec_version="$(sed -Ee "s/$VERSION_RE/\2/p" -n "$SPEC")"
status="$(git status --porcelain=v1)"

prepare() {
    new_version="$1"
    if [ -z "$new_version" ]; then
        printf '%s\n' "$spec_version"
        exit 16
    fi

    if [ -n "$status" ]; then
        printf '%s\n' "Working directory is not clean! Commit, stash, or discard your changes to continue."
        exit 2
    fi

    printf '%s\n' "appending new commits to $CHANGELOG"
    printf '\n## [%s]\n\n' "$new_version" >> "$CHANGELOG"
    defer_reset_hard_to="HEAD"
    {
        git log "v$spec_version.." --reverse --pretty=format:'%s' -z
        printf '\0'
    } | while read -rd $'\0' msg; do
        printf '%s\n' "- $msg" >> "$CHANGELOG"
    done

    printf '%s\n' "updating version in $SPEC..."
    sed -Ee "s/$VERSION_RE/\1$new_version\3/" -i "$SPEC"
    defer_reset_hard_to=""

    printf '%s\n\n\t%s\n' "The new version is ready to go. Edit the changelog, then run again with:" "$0 --continue"
}

release() {
    expected_status="$(printf ' M %s\n' "$CHANGELOG" "$SPEC")"
    if [ "$status" != "$expected_status" ]; then
        printf '%s\n' "Files other than $CHANGELOG and $SPEC have been modified. Please discard those changes."
        exit 2
    fi

    printf '%s\n' "committing changes..."
    defer_reset_to="HEAD"
    git add "$CHANGELOG" "$SPEC"
    git commit -m "prepare v$spec_version"
    defer_reset_to="HEAD^"

    printf '%s\n' "tagging new version..."
    tag="v$spec_version"
    git tag "$tag"
    defer_tag_delete="$tag"

    printf '%s\n' "pushing to origin..."
    git push origin "$tag"
    defer_tag_delete=""
    defer_reset_to=""
}

case "$1" in
    --continue)
        release
        ;;
    *)
        prepare "$1"
        ;;
esac
