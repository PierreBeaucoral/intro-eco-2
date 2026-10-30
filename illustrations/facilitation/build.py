#!/usr/bin/env python3
"""Compile les dix dessins TikZ et exporte les formats destinés au cours."""
from __future__ import annotations

import hashlib
import html
from itertools import combinations
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
import zipfile

from pypdf import PdfReader, PdfWriter

SOURCE = Path(__file__).resolve().parent
PROJECT = SOURCE.parents[1]
OUTPUT = PROJECT / "cours" / "img" / "facilitation-graphique"


def run(command: list[str], *, cwd: Path, env: dict[str, str] | None = None) -> str:
    """Exécute une commande et restitue le diagnostic en cas d'échec."""
    result = subprocess.run(command, cwd=cwd, env=env, capture_output=True, text=True)
    if result.returncode:
        raise RuntimeError(f"{command[0]} a échoué :\n{result.stdout}\n{result.stderr}")
    return result.stdout


def make_gallery(catalogue: list[dict[str, object]]) -> None:
    """Écrit une galerie locale, avec les descriptions et les liens de téléchargement."""
    cards = []
    for entry in catalogue:
        stem = str(entry["fichier"])
        title = html.escape(str(entry["titre"]))
        alt = html.escape(str(entry["alt"]), quote=True)
        cards.append(
            f'<article id="cm{entry["cm"]}"><h2>CM {entry["cm"]} · {title}</h2>'
            f'<img src="{stem}.svg" alt="{alt}" loading="lazy">'
            f'<p><a href="{stem}.pdf">PDF vectoriel</a> · '
            f'<a href="{stem}.svg">SVG</a> · <a href="{stem}.png">PNG</a></p></article>'
        )
    document = (
        '<!doctype html><html lang="fr"><meta charset="utf-8">'
        '<meta name="viewport" content="width=device-width,initial-scale=1">'
        '<title>Dix synthèses dessinées · Introduction à l’économie 2</title>'
        '<style>body{font:18px/1.5 system-ui;color:#212a32;margin:0 auto;padding:2rem;'
        'max-width:1400px;background:#fff}h1{font-size:2rem}h2{font-size:1.25rem}'
        'article{margin:3rem 0}img{display:block;width:100%;height:auto}'
        'a{color:#0062c4}nav{display:flex;gap:1rem;flex-wrap:wrap}'
        'a:focus-visible{outline:3px solid #b45309;outline-offset:4px}</style>'
        '<h1>Dix synthèses dessinées</h1><p>Introduction à l’économie 2 · '
        'Dessins entièrement en TikZ, fond blanc, format 16:9.</p>'
        '<p><a href="les-dix-cours.pdf">Recueil des dix cours</a> · '
        '<a href="dessins-tikz.zip">Sources et exports</a></p><nav>'
        + "".join(f'<a href="#cm{n}">CM {n}</a>' for n in range(1, 11))
        + '</nav>' + "".join(cards) + '</html>\n'
    )
    (OUTPUT / "galerie.html").write_text(document, encoding="utf-8")


def audit_nodes(path: Path, count: int = 10, size: tuple[float, float] = (32, 18)) -> dict[str, object]:
    """Mesure les boîtes TikZ : marges de 0,5 cm et écart de 0,3 cm entre textes."""
    cm_to_pt = 72.27 / 2.54
    pages: dict[int, list[tuple[float, ...]]] = {}
    for row in path.read_text(encoding="utf-8").splitlines():
        page, *values = row.split(",")
        bounds = tuple(float(value.removesuffix("pt")) / cm_to_pt for value in values)
        pages.setdefault(int(page), []).append(bounds)
    if set(pages) != set(range(1, count + 1)):
        raise RuntimeError(f"Le journal géométrique ne contient pas les {count} pages attendues")
    problems = []
    for number, boxes in pages.items():
        for index, box in enumerate(boxes):
            margin = min(box[0], box[1], size[0] - box[2], size[1] - box[3])
            if margin < 0.5 - 0.001:
                problems.append(f"CM {number}, texte {index} : marge {margin:.3f} cm")
        for (i, a), (j, b) in combinations(enumerate(boxes), 2):
            dx = max(a[0] - b[2], b[0] - a[2], 0)
            dy = max(a[1] - b[3], b[1] - a[3], 0)
            if dx < 0.3 - 0.001 and dy < 0.3 - 0.001:
                problems.append(f"CM {number}, textes {i}/{j} : écart insuffisant")
    if problems:
        raise RuntimeError("Audit géométrique :\n" + "\n".join(problems))
    return {"textes_mesures": sum(map(len, pages.values())),
            "marge_minimale_cm": 0.5, "ecart_minimal_textes_cm": 0.3,
            "collisions_textuelles": 0,
            "portee": "Boîtes des textes TikZ. Pictogrammes et flèches contrôlés visuellement."}


def make_archive() -> None:
    """Rassemble les sources et les exports ; exclut les journaux de compilation."""
    destination = OUTPUT / "dessins-tikz.zip"
    paths = sorted(p for p in SOURCE.rglob("*") if p.suffix in {".tex", ".py", ".md", ".json"})
    paths += sorted(p for p in OUTPUT.iterdir()
                    if p.suffix in {".pdf", ".svg", ".png", ".html", ".json", ".csv"})
    with zipfile.ZipFile(destination, "w", zipfile.ZIP_DEFLATED) as archive:
        for path in paths:
            info = zipfile.ZipInfo(str(path.relative_to(PROJECT)), (2026, 10, 22, 0, 0, 0))
            info.compress_type = zipfile.ZIP_DEFLATED
            archive.writestr(info, path.read_bytes())


def compile_source(name: str, work: Path, env: dict[str, str]) -> Path:
    """Compile une source TikZ ; refuse tout débordement ou avertissement de fonte."""
    run(["pdflatex", "-interaction=nonstopmode", "-halt-on-error",
         f"-output-directory={work}", f"{name}.tex"], cwd=SOURCE, env=env)
    log = (work / f"{name}.log").read_text(encoding="utf-8", errors="replace")
    warnings = re.findall(r"^.*(?:Overfull|Underfull|LaTeX Font Warning|Missing character).*$",
                          log, flags=re.MULTILINE)
    if warnings:
        raise RuntimeError(f"{name}.tex compilé avec avertissements :\n" + "\n".join(warnings))
    return work / f"{name}.pdf"


def export_page(page: object, stem: str, title: str) -> None:
    """Exporte une page en PDF vectoriel, SVG (site) et PNG (compatibilité)."""
    if list(page.images):
        raise RuntimeError(f"Bitmap inattendu dans {stem}")
    writer = PdfWriter()
    writer.add_page(page)
    writer.add_metadata({"/Title": title, "/Author": "Pierre Beaucoral"})
    pdf_path = OUTPUT / f"{stem}.pdf"
    with pdf_path.open("wb") as stream:
        writer.write(stream)
    run(["pdftocairo", "-svg", str(pdf_path), str(OUTPUT / f"{stem}.svg")], cwd=SOURCE)
    run(["pdftoppm", "-singlefile", "-scale-to-x", "1920", "-scale-to-y", "-1",
         "-png", str(pdf_path), str(OUTPUT / stem)], cwd=SOURCE)


# Planches de notion, hors des dix synthèses : source, export, titre, format (cm).
NOTIONS = [("positif-normatif", "cm1-positif-normatif",
            "Décrire un effet n'est pas choisir une politique", (32, 18)),
           ("positif-compact", "cm1-positif-compact", "Analyse positive", (16, 7.7)),
           ("normatif-compact", "cm1-normatif-compact", "Analyse normative", (16, 7.7))]


def build() -> None:
    """Compile une source unique puis découpe ses dix pages, sans duplication des dessins."""
    for executable in ("pdflatex", "pdftoppm", "pdftocairo"):
        if shutil.which(executable) is None:
            raise SystemExit(f"Commande manquante : {executable}")
    catalogue = json.loads((SOURCE / "catalogue.json").read_text(encoding="utf-8"))
    for entry in catalogue:
        source = (SOURCE / "planches" / f"cm{entry['cm']}.tex").read_text(encoding="utf-8")
        match = re.search(r"\\begin\{board\}\{\d+\}\{([^{}]+)\}", source)
        if match is None:
            raise RuntimeError(f"Titre introuvable pour le CM {entry['cm']}")
        entry["titre"] = match.group(1)
    OUTPUT.mkdir(parents=True, exist_ok=True)
    env = dict(os.environ, SOURCE_DATE_EPOCH="1792627200", FORCE_SOURCE_DATE="1")
    with tempfile.TemporaryDirectory(prefix="facilitation-tikz-") as temp:
        work = Path(temp)
        main_pdf = compile_source("main", work, env)
        audit = audit_nodes(work / "main.nodes.csv")
        shutil.copyfile(work / "main.nodes.csv", OUTPUT / "audit-noeuds.csv")
        (OUTPUT / "audit-geometrie.json").write_text(
            json.dumps(audit, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        reader = PdfReader(main_pdf)
        if len(reader.pages) != 10:
            raise RuntimeError(f"10 pages attendues, {len(reader.pages)} obtenues")
        for entry, page in zip(catalogue, reader.pages, strict=True):
            export_page(page, str(entry["fichier"]), str(entry["titre"]))
        shutil.copyfile(main_pdf, OUTPUT / "les-dix-cours.pdf")
        for name, stem, title, size in NOTIONS:
            pdf = compile_source(name, work, env)
            audit_nodes(work / f"{name}.nodes.csv", count=1, size=size)
            export_page(PdfReader(pdf).pages[0], stem, title)
    make_gallery(catalogue)
    hashes = {path.name: hashlib.sha256(path.read_bytes()).hexdigest()
              for path in sorted(OUTPUT.iterdir()) if path.suffix in {".pdf", ".svg", ".png"}}
    (OUTPUT / "manifest.json").write_text(
        json.dumps({"pages": 10, "format": "32 x 18 cm", "bitmaps_dans_les_pdf": 0,
                    "sha256": hashes}, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    make_archive()
    print(f"10 dessins compilés sans avertissement : {OUTPUT}")


if __name__ == "__main__":
    build()
