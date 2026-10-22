"""Write the Scoop manifest for a verified Windows package."""
import argparse
import hashlib
import json
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('--version', required=True)
parser.add_argument('--archive', type=Path, required=True)
parser.add_argument('--repository', default='li-sky/scoop-bucket')
parser.add_argument('--url')
parser.add_argument('--output', type=Path, default=Path('bucket/kbshare.json'))
args = parser.parse_args()
base = f'https://github.com/{args.repository}/releases/download'
manifest = {
    'version': args.version,
    'description': 'Share a keyboard, mouse and clipboard between Windows and Linux computers.',
    'homepage': 'https://github.com/li-sky/ununifying_kboard_share',
    'license': 'MIT',
    'architecture': {'64bit': {
        'url': args.url or f'{base}/kbshare-v{args.version}/kbshare-{args.version}-windows-x64.zip',
        'hash': hashlib.sha256(args.archive.read_bytes()).hexdigest(),
    }},
    'bin': ['kbshare.cmd', 'kbshare-config.cmd'],
    'shortcuts': [
        ['kbshare.exe', 'kbshare', '--config "$dir\\data\\config.json"'],
        ['kbshare-config.exe', 'kbshare Configuration', '"$dir\\data\\config.json" "kbshare"'],
    ],
    'persist': 'data',
    'checkver': {
        'url': f'https://api.github.com/repos/{args.repository}/releases/latest',
        'jsonpath': '$.tag_name',
        'regex': r'kbshare-v([\d.]+)',
    },
    'autoupdate': {'architecture': {'64bit': {
        'url': f'{base}/kbshare-v$version/kbshare-$version-windows-x64.zip',
        'hash': {'url': '$url.sha256'},
    }}},
    'notes': [
        'Run kbshare to open first-run setup, or kbshare-config to edit configuration.',
        'Settings, certificates, trust and logs are preserved in the Scoop persist/kbshare/data directory.',
        'Exit kbshare from its tray menu before updating.',
    ],
}
args.output.parent.mkdir(parents=True, exist_ok=True)
args.output.write_text(json.dumps(manifest, indent=4) + '\n', encoding='utf-8')
