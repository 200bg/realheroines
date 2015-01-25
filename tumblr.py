#!/usr/bin/env python3
import json

if __name__ == "__main__":
    fh = open('/home/oliverw/tmp/heroines-preview.json')
    rh_json = fh.read()
    heroines = json.loads(rh_json)

    html = """<h1>{0}</h1>
<p class="role">{1}</p>
<div class="blockquote">QUOTE</div>
<p><a class="realheroines-link" href="http://www.realheroines.com/portrait/{2}/" target="_blank">http://www.realheroines.com/portrait/{2}/</a></p>"""
    for h in heroines:
        print(html.format(h['name'], h['title'].upper(), h['slug']))
        print('\n')
        print('realheroines')
        print('\n')
        print('-------------------------')
        print('\n')
