import os
import psycopg2
from dotenv import load_dotenv
from flask import Flask, render_template, request, url_for, redirect

load_dotenv()  # Load .env file

POSTGRES_HOST = "localhost"
POSTGRES_DB_NAME = "postgres"
POSTGRES_USER = "postgres"
POSTGRES_PASSWORD = os.environ.get("POSTGRES_PASSWORD")


conn = psycopg2.connect(
    dbname=POSTGRES_DB_NAME,
    user=POSTGRES_USER,
    password=POSTGRES_PASSWORD,
    host=POSTGRES_HOST,
)
app = Flask(__name__)


@app.route("/status")
def status():
    return "I'm alive!!!"


@app.route("/restaurants/<restaurant_id>")
def restaurant_orders(restaurant_id: int):
    """
    Handle restaurant orders

    This function by default lists orders that restaurant has
    and information about that restaurant.
    If provided with `finishorder` param it also flags that
    order as finished.
    """

    orders = {}
    restaurant = {}
    cursor = conn.cursor()

    finishorder = request.args.get("finishorder", type=int)
    if finishorder is not None:
        cursor.execute(f"CALL RESTAURANT_MAKE_ORDER_READY({finishorder})")

    # List of dishes to finish (order_id, dish_name, qty)
    cursor.execute(f"SELECT * FROM RESTAURANT_LIST_ORDERS({restaurant_id})")
    results = cursor.fetchall()
    for dish in results:
        if dish[0] not in orders.keys():
            orders[dish[0]] = [(dish[1], dish[2])]
        else:
            orders[dish[0]] += [(dish[1], dish[2])]

    # Get restaurant info
    cursor.execute(f"SELECT * FROM RESTAURANT_INFO({restaurant_id})")
    results = cursor.fetchone()
    for i, desc in enumerate(cursor.description):
        restaurant[desc[0]] = results[i]

    conn.commit()
    cursor.close()

    return render_template(
        "restaurants.html",
        orders=orders,
        restaurant=restaurant,
        restaurant_id=restaurant_id,
        title="Restauracja " + restaurant["name"],
    )


@app.route("/addrestaurant")
def addrestaurant():
    """
    Adds restaurant

    By default it sends an empty from. If a user
    types something into it and clicks submit, all that
    data is send via GET request and I access it
    with `request.args.get`.

    Note that at least ONE dish has to be added.

    """
    restaurantname = request.args.get("restaurantname")
    email = request.args.get("email")
    phonenumber = request.args.get("phonenumber")
    address = request.args.get("address")
    street = request.args.get("street")
    postalcode = request.args.get("postalcode")
    city = request.args.get("city")

    dishnames = list(
        map(
            lambda y: request.args.get(y),
            filter(
                lambda x: "dishname" in x and request.args.get(x) != "",
                dict(request.args),
            ),
        )
    )

    dishprice = list(
        map(
            lambda y: request.args.get(y),
            filter(
                lambda x: "dishprice" in x and request.args.get(x) != "",
                dict(request.args),
            ),
        )
    )

    dishwait = list(
        map(
            lambda y: request.args.get(y),
            filter(
                lambda x: "dishwait" in x and request.args.get(x) != "",
                dict(request.args),
            ),
        )
    )

    dishes = [
        f"ARRAY{[dishnames[i], dishprice[i], dishwait[i]]}"
        for i in range(len(dishnames))
    ]

    dishes = f"ARRAY{dishes}".replace('"', "")

    cursor = conn.cursor()
    query = f"CALL RESTAURANTS_CREATE_RESTAURANT_IF_NOT_EXISTS('{restaurantname}','{email}','{phonenumber}','{address}','{street}','{postalcode}','{city}',{dishes})"
    if restaurantname is not None:
        try:
            cursor.execute(query)
            conn.commit()
            cursor.execute(
                f"SELECT id FROM RESTAURANTS WHERE name = '{restaurantname}'"
            )
            restaurantid = cursor.fetchone()[0]
            return redirect(url_for("restaurant_orders", restaurant_id=restaurantid))
        except Exception as e:
            print(e)
            cursor.close()
            conn.rollback()
            return render_template(
                "restaurants-create.html", warning=True, title="Dodaj restaurację"
            )
    return render_template("restaurants-create.html", title="Dodaj restaurację")


@app.route("/restaurants")
def restaurants_table():
    cursor = conn.cursor()
    cursor.execute(
        """
    SELECT r.id, r.name, ci.email, ci.phonenumber,
        addr.address, addr.street, addr.postalcode, cit.name
        FROM RESTAURANTS AS r
        INNER JOIN CONTACTINFO AS ci ON r.contactinfoid = ci.id
        INNER JOIN ADDRESS AS addr ON r.addressid = addr.id
        INNER JOIN CITIES AS cit ON addr.cityid = cit.id;"""
    )
    data = cursor.fetchall()

    cursor.close()
    conn.commit()

    return render_template(
        "restaurants-table.html", restaurants=data, title="Lista restauracji"
    )


@app.route("/employees/<int:employee_id>/take_order/<int:order_id>")
def take_order(employee_id: int, order_id: int):
    with conn.cursor() as cursor:
        cursor.execute(f"CALL take_order_from_restaurant({employee_id}, {order_id})")
    conn.commit()
    return redirect(url_for("get_employees"))


@app.route("/employees/<int:emp_id>/deliver_order/<int:order_id>")
def deliver_order(emp_id: int, order_id: int):
    with conn.cursor() as cursor:
        cursor.execute(f"CALL deliver_order({order_id})")
    conn.commit()
    return redirect(url_for("list_undelivered", emp_id=emp_id))


@app.route("/employees/<int:emp_id>/batch_deliver")
def batch_deliver(emp_id: int):
    orders = request.args.getlist("orders")
    orders = list(map(lambda x: int(x), orders))
    with conn.cursor() as cursor:
        cursor.execute(f"CALL batch_deliver(ARRAY{orders})")
    conn.commit()
    return redirect(url_for("list_undelivered", emp_id=emp_id))


@app.route("/employees/<int:emp_id>/undelivered")
def list_undelivered(emp_id):
    with conn.cursor() as cursor:
        cursor.execute(f"SELECT * FROM employees_list_undelivered_order({emp_id});")
        results = cursor.fetchall()
    return render_template(
        "employees_undelivered.html",
        data=results,
        title="Niedostarczone zamówienia",
        emp_id=emp_id,
    )


@app.route("/employees/<int:employee_id>/cities")
def list_available_orders(employee_id: int):
    city_id = request.args.get("city_id")
    with conn.cursor() as cursor:
        cursor.execute(
            f"SELECT * FROM employees_get_available_orders_to_take({city_id});"
        )
        results = cursor.fetchall()
    return render_template(
        "available_orders.html",
        data=results,
        emp_id=employee_id,
        title="Lista dostępnych zamówień",
    )


@app.route("/employees/<int:employee_id>/get_profit")
def get_employee_profit(employee_id):
    """
    Get employee's profit
    """
    end_date = request.args.get("end")
    start_date = request.args.get("start")
    with conn.cursor() as cursor:
        cursor.execute(
            f"SELECT * FROM employees_get_profit({employee_id}, '{start_date}', '{end_date}');"
        )
        results = cursor.fetchone()
    return render_template(
        "employee_profit.html",
        title="Zyski",
        money=(
            str(results[0]) + " zł"
            if results[0] is not None
            else "Nie zarobiłeś nic w zadanym okresie"
        ),
        startdate=start_date,
        enddate=end_date,
    )


@app.route("/employees")
def get_employees():
    """
    Show all employees
    """
    query = """
    select e.id, e.fname, e.lname, a.street, a.address, c.name, ci.email, ci.phonenumber
    from employees as e
    inner join address as a on a.id = e.addressid
    inner join cities as c on c.id = a.cityid
    inner join contactinfo as ci on e.contactinfoid = ci.id;
    """
    with conn.cursor() as cursor:
        cursor.execute(query)
        data = cursor.fetchall()

    return render_template(
        "employees_list.html", employees_data=data, title="Lista pracowników"
    )


@app.route("/employees/<int:emp_id>")
def get_employee(emp_id: int):
    """
    It's employee's dashboard

    It shows a bit of options:
    - take order - it's available after filtering the cities
    - get profit - show how much employee earned in given period
    - deliver order - deliver single order
    - deliver orders - deliver few orders
    Arguments
    ---------
    emp_id: int
        Employee's ID

    Returns
    -------
    Response
        Rendered template
    """
    query = "SELECT id, name from CITIES ORDER BY name;"
    with conn.cursor() as cursor:
        cursor.execute(query)
        cities = cursor.fetchall()
    return render_template(
        "employees_dashboard.html",
        emp_id=emp_id,
        cities=cities,
        title="Zarządzanie pracownikiem",
    )


@app.route("/addclient", methods=["GET", "POST"])
def addclient():
    """
    Dodanie klienta do bazy danych poprzez
    zapytanie typu POST. Wyświetla nam się
    strona z pustym formularzem, który
    należy wypełnić

    """

    if request.method == "POST":
        clientname = request.form.get("clientname_")
        email = request.form.get("email_")
        phonenumber = request.form.get("phonenumber_")
        street = request.form.get("street_")
        address = request.form.get("address_")
        postalcode = request.form.get("postalcode_")
        city = request.form.get("cityname_")

        cursor = conn.cursor()
        query = f"SELECT * FROM CREATE_CLIENT_IF_NOT_EXISTS('{clientname}','{email}','{phonenumber}','{address}','{street}','{postalcode}','{city}')"

        try:
            cursor.execute(query)
            conn.commit()
            return redirect("/clients")
        except Exception as e:
            print(e)
            cursor.close()
            conn.rollback()
            return render_template(
                "clients-create.html", warning=True, title="Dodaj klienta"
            )
    else:
        return render_template("clients-create.html", title="Dodaj klienta")


@app.route("/clients")
def clients_table():
    """
    Strona wyświetlająca informacje o klientach

    """
    cursor = conn.cursor()
    cursor.execute(
        """
    SELECT c.id, c.name, ci.email, ci.phonenumber,
        addr.address, addr.street, addr.postalcode, cit.name
        FROM CLIENTS AS c
        INNER JOIN CONTACTINFO AS ci ON c.contactinfoid = ci.id
        INNER JOIN ADDRESS AS addr ON c.addressid = addr.id
        INNER JOIN CITIES AS cit ON addr.cityid = cit.id;"""
    )
    data = cursor.fetchall()

    cursor.close()
    conn.commit()

    return render_template("clients-table.html", clients=data, title="Lista klientów")


@app.route("/available-restaurants")
def availablerestaurants():
    """
    Strona wykorzystywana do wybierania klienta
    w celu otrzymania informacji o dostępnych
    restauracjach dla klienta o danym ID.
    Z której jesteśmy przekierowani na stronę
    z tabelą wyświetlającą wszystkie dostępne
    restauracje w mieście klienta.

    """
    cursor = conn.cursor()
    cursor.execute(
        """
    SELECT c.id, c.name, ci.email, ci.phonenumber,
        addr.address, addr.street, addr.postalcode, cit.name
        FROM CLIENTS AS c
        INNER JOIN CONTACTINFO AS ci ON c.contactinfoid = ci.id
        INNER JOIN ADDRESS AS addr ON c.addressid = addr.id
        INNER JOIN CITIES AS cit ON addr.cityid = cit.id;"""
    )
    data = cursor.fetchall()

    cursor.close()
    conn.commit()

    return render_template(
        "clients_available_restaurants.html", title="Dostępne restauracje", clients=data
    )


@app.route("/available-restaurants-info")
def availablerestaurantsinfo():
    """
    Wyświetlenie informacji dot. dostępnych
    restauracji dla wybranego klienta
    o danym ID

    """

    try:
        clientid = request.args.get("client_id", type=int)
        cursor = conn.cursor()
        query = f"SELECT * FROM CLIENTS_AVAILABLE_RESTAURANTS({clientid})"
        cursor.execute(query)
        data = cursor.fetchall()
        cursor.close()
        conn.commit()
        return render_template("available-restaurants-info.html", restaurants=data)
    except Exception as e:
        print(e)
        cursor.close()
        conn.rollback()
        return render_template(
            "clients_available_restaurants.html",
            warning=True,
            title="Dostępne restauracje",
        )


@app.route("/available-dishes")
def availabledishes():
    """
    Strona wykorzystywana do wybierania klienta
    w celu otrzymania informacji o dostępnych
    daniach dla klienta o danym ID.
    Z której jesteśmy przekierowani na stronę
    z tabelą wyświetlającą wszystkie dostępne
    dania w mieście klienta.

    """

    cursor = conn.cursor()
    cursor.execute(
        """
    SELECT c.id, c.name, ci.email, ci.phonenumber,
        addr.address, addr.street, addr.postalcode, cit.name
        FROM CLIENTS AS c
        INNER JOIN CONTACTINFO AS ci ON c.contactinfoid = ci.id
        INNER JOIN ADDRESS AS addr ON c.addressid = addr.id
        INNER JOIN CITIES AS cit ON addr.cityid = cit.id;"""
    )
    data = cursor.fetchall()

    cursor.close()
    conn.commit()

    return render_template(
        "clients_available_dishes.html", title="Dostępne dania", clients=data
    )


@app.route("/available-dishes-info")
def availabledishesinfo():
    """
    Wyświetlenie informacji dot. dostępnych dań
    dla wybranego klienta o danym ID

    """

    try:
        clientid = request.args.get("client_id", type=int)
        cursor = conn.cursor()
        query = f"SELECT * FROM CLIENTS_AVAILABLE_DISHES({clientid})"
        cursor.execute(query)
        data = cursor.fetchall()
        cursor.close()
        conn.commit()
        return render_template("available-dishes-info.html", dishes=data)
    except Exception as e:
        print(e)
        cursor.close()
        conn.rollback()
        return render_template(
            "clients_available_dishes.html", warning=True, title="Dostępne dania"
        )


@app.route("/make-order-clients")
def makeorderclients():
    """
    Strona wyświetlająca listę klientów, na któej klient wybiera
    pozycję ze sobą, potem następuje przekierowanie na stronę
    /make-order

    """

    cursor = conn.cursor()
    cursor.execute(
        """
    SELECT c.id, c.name, ci.email, ci.phonenumber,
        addr.address, addr.street, addr.postalcode, cit.name
        FROM CLIENTS AS c
        INNER JOIN CONTACTINFO AS ci ON c.contactinfoid = ci.id
        INNER JOIN ADDRESS AS addr ON c.addressid = addr.id
        INNER JOIN CITIES AS cit ON addr.cityid = cit.id;"""
    )
    data = cursor.fetchall()

    cursor.close()
    conn.commit()

    return render_template(
        "make-order-clients.html", title="Składanie zamówienia", clients=data
    )


@app.route("/make-order", methods=["GET", "POST"])
def makeorder():
    """
    Strona zachowuje id klienta który został wybrany
    i pozwala wybrać danie poprzez id, ilość wybranego
    dania oraz rodzaj płatności.

    """
    if request.method == "POST":
        clientid = request.form.get("client_id")
        dishid = request.form.get("dish_id")
        quantity = request.form.get("quantity")
        paymenttype = request.form.get("payment_type")
        cursor = conn.cursor()
        query = (
            f"CALL CLIENTS_NEW_ORDER({clientid},{dishid},{quantity},'{paymenttype}')"
        )

        try:
            cursor.execute(query)
            conn.commit()
            return redirect("/clients")
        except Exception as e:
            print(e)
            cursor.close()
            conn.rollback()
            return render_template(
                "client_new_order.html", warning=True, title="Dodaj klienta"
            )
    else:
        clientid = request.args.get("client_id")

        return render_template(
            "client_new_order.html", title="Złóż zamówienie", clientid=clientid
        )
