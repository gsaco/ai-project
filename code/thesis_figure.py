"""Rebuild the motivating GDP figure and its quoted statistics from Stata exports."""
from reportlab.pdfgen.canvas import Canvas
import numpy as np
import pandas as pd


def read_results(directory, model):
    """Join coefficients and simultaneous intervals by horizon in five-year units."""
    estimates = pd.read_csv(directory / f'{model}_results.csv')
    bands = pd.read_csv(directory / f'{model}_supt_results.csv')
    for frame in (estimates, bands):
        if not frame['shock'].eq('shock1').all() or sorted(frame['horizon']) != [0, 1, 2, 3]:
            raise ValueError(f'Unexpected shock or horizons in the {model} export')
    return estimates.merge(bands, on=['shock', 'horizon'], validate='one_to_one').set_index('horizon').sort_index()


def response_path(results, suffix='', sign=1):
    """Map the signed slope and both sets of endpoints into the plotted response."""
    path = results[[f'b{suffix}', f'ci_low{suffix}', f'ci_high{suffix}',
                    f'ci_low{suffix}_supt_95', f'ci_high{suffix}_supt_95']].copy()
    path.columns = ['response', 'low', 'high', 'sim_low', 'sim_high']
    if sign == -1:
        path = -path[['response', 'high', 'low', 'sim_high', 'sim_low']].set_axis(path.columns, axis=1)
    ordered = path[['sim_low', 'low', 'response', 'high', 'sim_high']].to_numpy()
    if not np.isfinite(ordered).all() or (np.diff(ordered, axis=1) < 0).any():
        raise ValueError('The point or interval endpoints are out of order')
    path.index = path.index * 5
    return path


def draw_thesis_graph(output, panels):
    """Draw the thesis layout in PDF points; every ordinate comes from a Stata result frame."""
    page = Canvas(str(output), pagesize=(892.8, 453.6), invariant=True)
    page.setTitle("GDP responses to economic freedom shocks")
    # The original plot places zero at 239.24 pt, with 56.33 pt between 0.20-unit ticks.
    def y(value):
        return 239.2425 + value * 281.65

    for offset, curves in zip((0, 432.80), panels):
        page.saveState()
        page.translate(offset, 0)
        left, right = 87.24, 421.46
        years = (0, 5, 10, 15)
        def x(year):
            return 94.02 + year * 21.147

        page.setFont("Helvetica", 9.458)
        for tick in range(-3, 4):
            value = tick / 5
            page.setLineWidth(0.51)
            page.setDash(3.63, 3.17)
            page.setStrokeGray(0.628 if tick == 0 else 0.878)
            page.line(left, y(value), right, y(value))
            page.setDash()
            page.setStrokeGray(0)
            page.setLineWidth(0.68)
            page.line(left - 4.74, y(value), left, y(value))
            page.drawRightString(79.88, y(value) - 3.29, f"{value:.2f}")
        for year in years:
            page.drawCentredString(x(year), 57.89, str(year))
        page.setFont("Helvetica-Bold", 11.802)
        page.drawCentredString(252.65, 33.68, "Years after EFW change")
        page.saveState()
        page.translate(38.42, 0)
        page.rotate(90)
        page.drawString(133.07, 0, "Cumulative GDP response (log points)")
        page.restoreState()

        for values, color in curves:
            for low, high, opacity in (("sim_low", "sim_high", .10), ("low", "high", .20)):
                band = page.beginPath()
                band.moveTo(x(0), y(values.loc[0, high]))
                for year in years[1:]:
                    band.lineTo(x(year), y(values.loc[year, high]))
                for year in reversed(years):
                    band.lineTo(x(year), y(values.loc[year, low]))
                band.close()
                page.saveState()
                page.setFillColorRGB(*(0.2 + 0.8 * c for c in color), alpha=opacity)
                page.setStrokeColorRGB(*color, alpha=opacity)
                page.setLineWidth(2.04)
                page.clipPath(band, stroke=0, fill=1)
                page.drawPath(band, stroke=1, fill=0)
                page.restoreState()
            line = page.beginPath()
            line.moveTo(x(0), y(values.loc[0, "response"]))
            for year in years[1:]:
                line.lineTo(x(year), y(values.loc[year, "response"]))
            page.setStrokeColorRGB(*color)
            page.setLineWidth(.85)
            page.drawPath(line)
        page.restoreState()

    page.setFont("Helvetica", 9.458)
    for start, label, color in [(566.93, "Improvement", (0, .502, 0)),
                                (698.20, "Deterioration", (1, 0, 0))]:
        page.setStrokeColorRGB(*color)
        page.setLineWidth(.85)
        page.line(start, 81.94, start + 44.22, 81.94)
        page.drawString(start + 53.68, 78.65, label)
    page.save()


def reproduce_thesis_figure(root):
    directory = root / 'code/data/thesis-irfs'
    symmetric = read_results(directory, 'sym')
    asymmetric = read_results(directory, 'asym')
    average = response_path(symmetric)
    gain = response_path(asymmetric, '_pos')
    loss = response_path(asymmetric, '_neg', sign=-1)

    # Independent rounded targets are Panels A, B and C of the original thesis table.
    reported = np.column_stack([average.response, gain.response, loss.response, asymmetric.p_sym])
    expected = [[.084, .069, -.111, .482], [.156, .099, -.274, .029],
                [.177, .082, -.358, .004], [.148, .096, -.247, .170]]
    if not np.array_equal(np.round(reported, 3), expected):
        raise ValueError('The exported estimates or equality tests disagree with the thesis table')
    if not symmetric.N.equals(asymmetric.N) or list(asymmetric.N) != [1109, 946, 759, 635]:
        raise ValueError('Estimation samples differ from the original table')

    quoted = {
        'irfGainTen': gain.loc[10, 'response'],
        'irfDeteriorationTen': loss.loc[10, 'response'],
        'irfGapTen': -loss.loc[10, 'response'] - gain.loc[10, 'response'],
        'irfTestTen': asymmetric.loc[2, 'p_sym'],
        'irfTestFifteen': asymmetric.loc[3, 'p_sym'],
    }
    figdir = root / 'paper/figures'
    texdir = root / 'paper/tables'
    figdir.mkdir(exist_ok=True)
    texdir.mkdir(exist_ok=True)
    draw_thesis_graph(figdir / 'thesis-irfs.pdf',
                     [[(average, (0, 0, 1))], [(gain, (0, .502, 0)), (loss, (1, 0, 0))]])
    (texdir / 'thesis-irf-values.tex').write_text(''.join(
        rf'\newcommand{{\{name}}}{{{value:.3f}}}' + '\n' for name, value in quoted.items()))
    return {name: float(value) for name, value in quoted.items()}
