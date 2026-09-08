import requests
from typing import Any
import json
import sys
import time

SYSTEMET_URL = "https://www.systembolaget.se"
SYSTEMET_URL_SORTIMENT = f"{SYSTEMET_URL}/sortiment"

OCP_APIM_SUBSCRIPTION_KEY = "8d39a7340ee7439f8b4c1e995c8f3e4a"
SYSTEMET_HEADERS = {"ocp-apim-subscription-key": OCP_APIM_SUBSCRIPTION_KEY}

SIZE = 30

products = []


def get_page_url(
    page: int, size: int, category_level_1: str, category_level_2: str | None = None
) -> str:
    url = f"https://api-extern.systembolaget.se/sb-api-ecommerce/v2/productsearch/search?page={page}&size={size}&sortBy=Score&sortDirection=Ascending&categoryLevel1={category_level_1}"
    if category_level_2 is not None:
        url += f"&categoryLevel2={category_level_2}"

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
        ("Vin", "Vinlåda"),
        ("Öl", None),
        ("Sprit", None),
        ("Cider & blanddrycker", None),
        ("Alkoholfritt", None),
        ("Presentartiklar", None),
    ]

    for category_level_1, category_level_2 in categories:
        data = http_get_json(get_page_url(1, 30, category_level_1, category_level_2))
        page_count = data["metadata"]["totalPages"]
        print(category_level_1, category_level_2, page_count)

        # for page in range(1, page_count + 1):
        #     print(
        #         f"fetching {category_level_1}, {category_level_2} {page}/{page_count}"
        #     )
        #     url = get_page_url(page, SIZE, category_level_1, category_level_2)
        #     data = http_get_json(url)
        #     data_products = data["products"]
        #     products.extend(data_products)
        #     print(f"fetched {category_level_1}, {category_level_2} {page}/{page_count}")
        #     time.sleep(2)


def main():
    get_sortiment()

    with open("products.json", "w") as f:
        json.dump(products, f)


if __name__ == "__main__":
    main()
