
![App Screenshot](https://via.placeholder.com/468x300?text=App+Screenshot+Here)


# Bromelia CLI

Developed by [Bromelia](https://bromelia.io/) 🌺


**Bromelia CLI** is a command-line tool for generating Flutter projects. 

The generated project comes pre-configured with:

- **Navigation** via [go_router](https://pub.dev/packages/go_router)
- **Theming** with [theme_tailor](https://pub.dev/packages/theme_tailor)
- **Localization** (intl, flutter_localizations)
- **Responsiveness** using [responsive_builder](https://pub.dev/packages/responsive_builder)

## 🚀 Installation
```sh
dart pub global activate bromelia_cli
```

### Create a New Flutter Project

```sh
bromelia_cli create [--org <organization>] [--platforms <platforms>] <project_name>
```

#### **Options**

- `--org`, `-o`  
  Organization domain (optional, default: `com.example`)  
  Example: `com.mycompany`

- `--platforms`, `-p`  
  Target platforms (optional, comma-separated)  
  Default: all platforms (`android,ios,web,windows,macos,linux`)  
  Available: `android`, `ios`, `web`, `windows`, `macos`, `linux`

#### **Examples**

```sh
bromelia_cli create my_app
bromelia_cli create --org com.mycompany my_app
bromelia_cli create --org com.mycompany --platforms android,ios my_app
bromelia_cli create --platforms web my_web_app
```

## 🐞 Troubleshooting

- **Flutter not found**  
  Make sure Flutter is installed and available in your `PATH`.


## 📄 License

MIT

---

**Happy coding!**



