# This file is part of wger Workout Manager.
#
# wger Workout Manager is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# wger Workout Manager is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License

# /// script
# requires-python = ">=3.13"
# dependencies = [
#   "requests == 2.31.0",
#   "markdown == 3.5.1",
# ]
# ///


"""
Updates the Flatpak metainfo.xml file with the given version.

Usage:
    uv run bump-flatpak-version.py x.y.z
"""

import sys
import xml.etree.ElementTree as ET
from datetime import datetime
from typing import Tuple

import markdown
import requests

REPO = "wger-project/flutter"


def get_github_release_info(repo: str, version: str) -> Tuple[str, str]:
    """
    Fetches the release description and published_at date from GitHub for the given repository
    and version. The description is converted fro markdown and returned as HTML.
    """

    print('Fetching release information from GitHub...')
    url = f'https://api.github.com/repos/{repo}/releases/tags/{version}'
    response = requests.get(url)
    response.raise_for_status()
    data = response.json()
    html_desc = markdown.markdown(data.get('body', ''))

    # Get the published_at date, formatted as YYYY-MM-DD, we don't need the time part
    published_at = data.get('published_at', '')[:10]
    return html_desc, published_at


def add_release_to_metainfo(
        repo: str,
        xml_filename: str,
        version: str,
        date: str | None = None,
        description: str | None = None
) -> None:
    """
    Adds a <release> element with the specified version and date to the <releases>
    section in the given metainfo.xml file.

    If a description is provided, it will be added as a child element of the
    <release> element.
    """
    print(f'Adding release to {xml_filename}...')

    if date is None:
        date = datetime.now().strftime('%Y-%m-%d')

    if description is None:
        description = '<p>Bug fixes and improvements.</p>'

    tree = ET.parse(xml_filename)
    root = tree.getroot()
    releases = root.find('releases')
    new_release = ET.Element('release', {'version': version, 'date': date})
    if description:
        desc_elem = ET.SubElement(new_release, 'description')

        # Needed to add HTML content directly, otherwise it will be escaped
        fragment = ET.fromstring(f'<root>{description}</root>')
        for child in fragment:
            desc_elem.append(child)

    url_elem = ET.SubElement(new_release, 'url')
    url_elem.text = f'https://{repo}/releases/tag/{version}'

    releases.insert(0, new_release)
    ET.indent(tree, space="    ", level=0)
    tree.write(xml_filename, encoding="utf-8", xml_declaration=True)


if __name__ == '__main__':
    if len(sys.argv) != 2:
        print('Usage: python bump-flatpak-version.py <x.y.z>')
        sys.exit(1)

    version = sys.argv[1]

    print(f'Processing version {version}...')

    # Note: it seems it's currently not possible to update existing releases on
    #       GitHub with softprops/action-gh-release.
    #
    #       Once that's fixed, we can update the workflows to first create the
    #       release and its changelog, and in a later step only update the artifacts.
    #       We can then simply fetch the description and update the metainfo.xml file.
    #
    #       See
    #       * https://github.com/softprops/action-gh-release/issues/616
    #       * https://github.com/softprops/action-gh-release/issues/445

    # description, published_at = get_github_release_info(
    #     REPO,
    #     version
    # )

    add_release_to_metainfo(
        repo=REPO,
        xml_filename='de.wger.flutter.metainfo.xml',
        version=version,
        date=None,  # published_at,
        description=None  # description
    )

    print(f'Finished!')
