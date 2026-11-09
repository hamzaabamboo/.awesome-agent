import re
import struct
import sys

NAV_IDS = {"Session": 6, "Tabs": 1}
SELECT_IDS = {"Session": 7, "Tabs": 4}


def parse(path):
    data = open(path, "rb").read()
    kind = "Tabs" if path.split("/")[-1].startswith("Tabs_") else "Session"
    nav_id, select_id = NAV_IDS[kind], SELECT_IDS[kind]
    pos = 8
    tabs, selected, closed, pinned = {}, {}, set(), set()
    while pos + 3 <= len(data):
        size, = struct.unpack_from("<H", data, pos)
        cmd = data[pos + 2]
        payload = data[pos + 3:pos + 2 + size]
        pos += 2 + size
        try:
            if cmd == nav_id:
                tab, index = struct.unpack_from("<ii", payload, 4)
                length, = struct.unpack_from("<i", payload, 12)
                url = payload[16:16 + length].decode("latin1")
                offset = 16 + ((length + 3) // 4) * 4
                title_len, = struct.unpack_from("<i", payload, offset)
                title = payload[offset + 4:offset + 4 + title_len * 2].decode("utf-16le", "replace")
                tabs.setdefault(tab, {})[index] = (url, title)
            elif cmd == select_id:
                tab, index = struct.unpack_from("<ii", payload, 0)
                selected[tab] = index
            elif kind == "Session" and cmd == 16:
                closed.add(struct.unpack_from("<i", payload, 0)[0])
            elif kind == "Session" and cmd == 12:
                pinned.add(struct.unpack_from("<i", payload, 0)[0])
        except struct.error:
            pass
    for tab, navs in tabs.items():
        if tab in closed:
            continue
        url, title = navs.get(selected.get(tab, max(navs)), navs[max(navs)])
        yield ("P" if tab in pinned else ""), title, url


if __name__ == "__main__":
    for pin, title, url in parse(sys.argv[1]):
        if re.match(r"https?://", url):
            print(f"{pin}\t{title}\t{url}")
