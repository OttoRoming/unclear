import requests
from typing import Any
import json
import sys
import time
import urllib.parse

SYSTEMET_URL = "https://www.systembolaget.se"
SYSTEMET_URL_SORTIMENT = f"{SYSTEMET_URL}/sortiment"

OCP_APIM_SUBSCRIPTION_KEY = "8d39a7340ee7439f8b4c1e995c8f3e4a"
SYSTEMET_HEADERS = {"ocp-apim-subscription-key": OCP_APIM_SUBSCRIPTION_KEY}

SIZE = 30

products: dict[str, Any] = {}


def get_page_url(
    page: int, size: int, category_level_1: str, category_level_2: str | None = None
) -> str:
    url = f"https://api-extern.systembolaget.se/sb-api-ecommerce/v2/productsearch/search?page={page}&size={size}&sortBy=Score&sortDirection=Ascending&categoryLevel1={urllib.parse.quote(category_level_1)}"
    if category_level_2 is not None:
        url += f"&categoryLevel2={urllib.parse.quote(category_level_2)}"

    return url


def http_get_json(url: str) -> dict[Any, Any]:
    r = requests.get(url, headers=SYSTEMET_HEADERS)
    if not r.ok:
        print(r.status_code)
        print(r.headers)
        print(r.text)
        sys.exit(1)

    return r.json()


def get_sortiment():
    categories = [
        ("Vin", "Rött vin"),
        ("Vin", "Vitt vin"),
        ("Vin", "Mousserande vin"),
        ("Vin", "Rosévin"),
        ("Vin", "Starkvin"),
        ("Vin", "Vinlåda"),
        ("Vin", "Smaksatt vin & fruktvin"),
        ("Vin", "Glögg och Glühwein"),
        ("Vin", "Vermouth"),
        ("Vin", "Aperitifer"),
        ("Vin", "Sake"),
        ("Vin", "Drycker av flera typer"),
        ("Öl", None),
        ("Sprit", None),
        ("Cider & blanddrycker", None),
        ("Alkoholfritt", None),
        ("Presentartiklar", None),
    ]

    for category_level_1, category_level_2 in categories:
        data = http_get_json(get_page_url(1, 30, category_level_1, category_level_2))
        page_count = data["metadata"]["totalPages"]

        for page in range(1, page_count + 1):
            log_page_identifier = f"{category_level_1}, {category_level_2} {page}/{page_count}"
            print(f"get  {log_page_identifier}")

            url = get_page_url(page, SIZE, category_level_1, category_level_2)
            data = http_get_json(url)
            data_products = data["products"]

            for product in data_products:
                id = product["productId"]
                products[id] = product

            print(f"done {log_page_identifier}")
            time.sleep(1)


def main():
    get_sortiment()

    with open("products.json", "w") as f:
        json.dump(products, f)


if __name__ == "__main__":
    main()
